-- =====================================================
-- SAFE RLS POLICIES SCRIPT (with existence checks)
-- =====================================================

-- Drop existing policies if they exist (optional - uncomment if needed)
-- DROP POLICY IF EXISTS "Users can view own transactions" ON public.wallet_transactions;
-- DROP POLICY IF EXISTS "Users can create own transactions" ON public.wallet_transactions;

-- Create policies only if they don't exist
DO $$ 
BEGIN
    -- Check and create policy for viewing transactions
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'wallet_transactions' 
        AND policyname = 'Users can view own transactions'
    ) THEN
        CREATE POLICY "Users can view own transactions" ON public.wallet_transactions
            FOR SELECT USING (
                wallet_id IN (
                    SELECT id FROM public.wallets WHERE user_id = auth.uid()
                )
            );
    END IF;

    -- Check and create policy for creating transactions
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'wallet_transactions' 
        AND policyname = 'Users can create own transactions'
    ) THEN
        CREATE POLICY "Users can create own transactions" ON public.wallet_transactions
            FOR INSERT WITH CHECK (
                wallet_id IN (
                    SELECT id FROM public.wallets WHERE user_id = auth.uid()
                )
            );
    END IF;
END $$;

-- =====================================================
-- FUNCTIONS FOR SECURE OPERATIONS (Main focus)
-- =====================================================

-- Drop existing functions if they exist
DROP FUNCTION IF EXISTS public.add_wallet_points(INTEGER, VARCHAR(50), TEXT);
DROP FUNCTION IF EXISTS public.use_wallet_points(INTEGER, UUID, JSONB);

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

-- =====================================================
-- Quick check to see current RLS status
-- =====================================================
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename IN ('wallets', 'wallet_transactions')
ORDER BY tablename, policyname;