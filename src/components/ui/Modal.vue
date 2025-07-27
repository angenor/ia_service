<template>
  <Teleport to="body">
    <Transition name="modal">
      <div v-if="modelValue" class="fixed inset-0 z-50 overflow-y-auto">
        <!-- Backdrop -->
        <div 
          class="fixed inset-0 bg-black bg-opacity-50 dark:bg-opacity-70 transition-opacity"
          @click="$emit('update:modelValue', false)"
        ></div>
        
        <!-- Modal -->
        <div class="flex min-h-full items-center justify-center p-4">
          <div 
            class="relative w-full max-w-md transform overflow-hidden rounded-2xl bg-white dark:bg-gray-800 p-6 text-left align-middle shadow-xl transition-all"
            @click.stop
          >
            <!-- Close button -->
            <button
              @click="$emit('update:modelValue', false)"
              class="absolute right-4 top-4 text-gray-400 hover:text-gray-500 dark:hover:text-gray-300"
            >
              <font-awesome-icon icon="times" class="w-5 h-5" />
            </button>
            
            <!-- Title -->
            <h2 v-if="title" class="text-xl font-semibold text-gray-900 dark:text-white mb-4">
              {{ title }}
            </h2>
            
            <!-- Content -->
            <div>
              <slot></slot>
            </div>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
defineProps({
  modelValue: {
    type: Boolean,
    required: true
  },
  title: {
    type: String,
    default: ''
  }
})

defineEmits(['update:modelValue'])
</script>

<style scoped>
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.3s ease;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-active .relative,
.modal-leave-active .relative {
  transition: all 0.3s ease;
}

.modal-enter-from .relative {
  opacity: 0;
  transform: scale(0.95);
}

.modal-leave-to .relative {
  opacity: 0;
  transform: scale(0.95);
}
</style>