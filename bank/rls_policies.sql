-- =====================================================
-- ROW LEVEL SECURITY POLICIES
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallet_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_usage ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.promotion_usage ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- PROFILES POLICIES
-- =====================================================

-- Users can view their own profile
CREATE POLICY "Users can view own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

-- Users can insert their own profile
CREATE POLICY "Users can insert own profile" ON public.profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- =====================================================
-- WALLETS POLICIES
-- =====================================================

-- Users can view their own wallet
CREATE POLICY "Users can view own wallet" ON public.wallets
    FOR SELECT USING (auth.uid() = user_id);

-- Users can create their own wallet
CREATE POLICY "Users can create own wallet" ON public.wallets
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own wallet
CREATE POLICY "Users can update own wallet" ON public.wallets
    FOR UPDATE USING (auth.uid() = user_id);

-- =====================================================
-- WALLET TRANSACTIONS POLICIES
-- =====================================================

-- Users can view their own transactions
CREATE POLICY "Users can view own transactions" ON public.wallet_transactions
    FOR SELECT USING (
        wallet_id IN (
            SELECT id FROM public.wallets WHERE user_id = auth.uid()
        )
    );

-- Users can create transactions for their own wallet
CREATE POLICY "Users can create own transactions" ON public.wallet_transactions
    FOR INSERT WITH CHECK (
        wallet_id IN (
            SELECT id FROM public.wallets WHERE user_id = auth.uid()
        )
    );

-- =====================================================
-- SERVICE USAGE POLICIES
-- =====================================================

-- Users can view their own service usage
CREATE POLICY "Users can view own service usage" ON public.service_usage
    FOR SELECT USING (auth.uid() = user_id);

-- Users can create their own service usage records
CREATE POLICY "Users can create own service usage" ON public.service_usage
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own service usage records
CREATE POLICY "Users can update own service usage" ON public.service_usage
    FOR UPDATE USING (auth.uid() = user_id);

-- =====================================================
-- PROMOTION USAGE POLICIES
-- =====================================================

-- Users can view their own promotion usage
CREATE POLICY "Users can view own promotion usage" ON public.promotion_usage
    FOR SELECT USING (auth.uid() = user_id);

-- Users can create their own promotion usage records
CREATE POLICY "Users can create own promotion usage" ON public.promotion_usage
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- =====================================================
-- PUBLIC READ POLICIES (for non-user specific data)
-- =====================================================

-- Everyone can read service categories
CREATE POLICY "Service categories are viewable by everyone" ON public.service_categories
    FOR SELECT USING (true);

-- Everyone can read service subcategories
CREATE POLICY "Service subcategories are viewable by everyone" ON public.service_subcategories
    FOR SELECT USING (true);

-- Everyone can read active AI services
CREATE POLICY "Active AI services are viewable by everyone" ON public.ai_services
    FOR SELECT USING (is_active = true);

-- Everyone can read service pricing for their country
CREATE POLICY "Service pricing viewable by country" ON public.service_pricing_by_country
    FOR SELECT USING (true);

-- Everyone can read service availability
CREATE POLICY "Service availability viewable by everyone" ON public.service_availability
    FOR SELECT USING (true);

-- Everyone can read active promotions
CREATE POLICY "Active promotions viewable by everyone" ON public.promotions
    FOR SELECT USING (is_active = true AND (valid_until IS NULL OR valid_until > NOW()));

-- =====================================================
-- ADMIN POLICIES
-- =====================================================

-- Admins can do everything on all tables
CREATE POLICY "Admins have full access to profiles" ON public.profiles
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE id = auth.uid() AND is_admin = true
        )
    );

CREATE POLICY "Admins have full access to wallets" ON public.wallets
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE id = auth.uid() AND is_admin = true
        )
    );

CREATE POLICY "Admins have full access to wallet_transactions" ON public.wallet_transactions
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE id = auth.uid() AND is_admin = true
        )
    );

CREATE POLICY "Admins have full access to service_usage" ON public.service_usage
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE id = auth.uid() AND is_admin = true
        )
    );

-- =====================================================
-- FUNCTIONS FOR SECURE OPERATIONS
-- =====================================================

-- Function to safely add points to wallet (with transaction)
CREATE OR REPLACE FUNCTION public.add_wallet_points(
    p_amount INTEGER,
    p_payment_method VARCHAR(50) DEFAULT 'simulation',
    p_payment_reference TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_wallet_id UUID;
    v_new_balance INTEGER;
    v_transaction_id UUID;
BEGIN
    -- Get user's wallet
    SELECT id, balance INTO v_wallet_id, v_new_balance
    FROM wallets
    WHERE user_id = auth.uid()
    FOR UPDATE;
    
    IF v_wallet_id IS NULL THEN
        RAISE EXCEPTION 'Wallet not found for user';
    END IF;
    
    -- Calculate new balance
    v_new_balance := v_new_balance + p_amount;
    
    -- Update wallet balance
    UPDATE wallets
    SET balance = v_new_balance,
        updated_at = NOW()
    WHERE id = v_wallet_id;
    
    -- Create transaction record
    INSERT INTO wallet_transactions (
        wallet_id,
        amount,
        type,
        payment_method,
        payment_reference,
        status,
        completed_at
    ) VALUES (
        v_wallet_id,
        p_amount,
        'deposit',
        p_payment_method,
        COALESCE(p_payment_reference, 'SIM-' || extract(epoch from NOW())::TEXT),
        'completed',
        NOW()
    ) RETURNING id INTO v_transaction_id;
    
    -- Return result
    RETURN jsonb_build_object(
        'success', true,
        'transaction_id', v_transaction_id,
        'new_balance', v_new_balance
    );
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', SQLERRM
        );
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.add_wallet_points TO authenticated;

-- Function to use points from wallet
CREATE OR REPLACE FUNCTION public.use_wallet_points(
    p_amount INTEGER,
    p_service_id UUID DEFAULT NULL,
    p_metadata JSONB DEFAULT '{}'
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_wallet_id UUID;
    v_current_balance INTEGER;
    v_new_balance INTEGER;
BEGIN
    -- Get user's wallet with lock
    SELECT id, balance INTO v_wallet_id, v_current_balance
    FROM wallets
    WHERE user_id = auth.uid()
    FOR UPDATE;
    
    IF v_wallet_id IS NULL THEN
        RAISE EXCEPTION 'Wallet not found for user';
    END IF;
    
    -- Check sufficient balance
    IF v_current_balance < p_amount THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Insufficient balance',
            'current_balance', v_current_balance,
            'required_amount', p_amount
        );
    END IF;
    
    -- Calculate new balance
    v_new_balance := v_current_balance - p_amount;
    
    -- Update wallet balance
    UPDATE wallets
    SET balance = v_new_balance,
        updated_at = NOW()
    WHERE id = v_wallet_id;
    
    -- Return result
    RETURN jsonb_build_object(
        'success', true,
        'new_balance', v_new_balance,
        'amount_used', p_amount
    );
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', SQLERRM
        );
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.use_wallet_points TO authenticated;