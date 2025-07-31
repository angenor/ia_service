⚠️ Content-Type inattendu: text/event-stream LLMService.vue:235:15
Contenu brut reçu: : OPENROUTER PROCESSING

data: {"id":"gen-1753932698-cukvHDojm0vTvKTrYY7r","provider":"Google","model":"google/gemini-2.5-flash","object":"chat.completion.chunk","created":1753932698,"choices":[{"index":0,"delta":{"role":"assistant","content":"Salut","reasoning":null,"reasoning_details":[]},"finish_reason":null,"native_finish_reason":null,"logprobs":null}]}

data: {"id":"gen-1753932698-cukvHDojm0vTvKTrYY7r","provider":"Google","model":"google/gemini-2.5-flash","object":"chat.completion.chunk","c LLMService.vue:237:15
LLM Error: Error: La réponse n'est pas du JSON valide
    handleGenerate LLMService.vue:238
    callWithErrorHandling runtime-core.esm-bundler.js:199
    callWithAsyncErrorHandling runtime-core.esm-bundler.js:206
    emit runtime-core.esm-bundler.js:6439
    createSetupContext/get emit/< runtime-core.esm-bundler.js:8152
    handleGenerate ServiceInputSection.vue:519
    callWithErrorHandling runtime-core.esm-bundler.js:199
    callWithAsyncErrorHandling runtime-core.esm-bundler.js:206
    invoker runtime-dom.esm-bundler.js:729
    addEventListener runtime-dom.esm-bundler.js:680
    patchEvent runtime-dom.esm-bundler.js:698
    patchProp runtime-dom.esm-bundler.js:775
    mountElement runtime-core.esm-bundler.js:4900
    processElement runtime-core.esm-bundler.js:4847
    patch runtime-core.esm-bundler.js:4715
    mountChildren runtime-core.esm-bundler.js:4959
    mountElement runtime-core.esm-bundler.js:4882
    processElement runtime-core.esm-bundler.js:4847
    patch runtime-core.esm-bundler.js:4715
    mountChildren runtime-core.esm-bundler.js:4959
    mountElement runtime-core.esm-bundler.js:4882
    processElement runtime-core.esm-bundler.js:4847
    patch runtime-core.esm-bundler.js:4715
    mountChildren runtime-core.esm-bundler.js:4959
    mountElement runtime-core.esm-bundler.js:4882
    processElement runtime-core.esm-bundler.js:4847
    patch runtime-core.esm-bundler.js:4715
    mountChildren runtime-core.esm-bundler.js:4959
    processFragment runtime-core.esm-bundler.js:5139
    patch runtime-core.esm-bundler.js:4701
    mountChildren runtime-core.esm-bundler.js:4959
    mountElement runtime-core.esm-bundler.js:4882
    processElement runtime-core.esm-bundler.js:4847
    patch runtime-core.esm-bundler.js:4715
    componentUpdateFn runtime-core.esm-bundler.js:5353
    run reactivity.esm-bundler.js:237
    setupRenderEffect runtime-core.esm-bundler.js:5481
    mountComponent runtime-core.esm-bundler.js:5256
    processComponent runtime-core.esm-bundler.js:5209
LLMService.vue:294:13