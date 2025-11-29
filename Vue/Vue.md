## ref vs reactive

### ref

- Purpose: Primarily designed for making primitive values (strings, numbers, booleans, null, undefined, BigInt, Symbol) reactive. It can also be used for objects or arrays, but its main advantage lies with primitives.
- Mechanism: ref wraps the value inside an object with a .value property. This object itself is reactive, and Vue tracks changes to the .value property.
- Usage: To access or modify the value, you need to use the .value property.

### reactive

- Purpose: Designed for making objects and arrays reactive. It directly makes the object or array a reactive proxy.
- Mechanism: reactive takes an object and returns a reactive proxy of that object. Vue intercepts access and mutation of all properties within this proxy for reactivity tracking.
- Usage: You directly access and modify the properties of the reactive object, similar to a regular JavaScript object.

```jsx
import { ref } from 'vue';

const count = ref(0);
console.log(count.value); // Accessing the value
count.value++; // Modifying the value

const message = ref('Hello');
console.log(message.value);

// ------------------------------

import { reactive } from 'vue';

const state = reactive({
    name: 'Alice',
    age: 30,
    hobbies: ['reading', 'hiking']
});

console.log(state.name); // Accessing a property
state.age++; // Modifying a property
state.hobbies.push('cooking'); // Modifying an array within the object
```

## watch and watchEffect

### watch

- Explicit Dependency Tracking: watch requires you to explicitly specify the source(s) it should observe. This can be a ref, a reactive object, a computed property, or even a function that returns a value.
- Lazy Execution (by default): The callback function provided to watch is not executed immediately when the component mounts. It only runs when the watched source actually changes. You can force immediate - execution by setting the immediate: true option.
- Access to Old and New Values: The callback function receives both the new value and the old value of the watched source(s) as arguments, allowing for comparisons and more controlled side effects.
- Precise Control: watch offers more fine-grained control over what triggers the side effect, as you define the exact dependencies.

### watchEffect

- Automatic Dependency Tracking: watchEffect automatically tracks any reactive properties accessed within its callback function during its synchronous execution. You do not need to explicitly declare sources.
- Immediate Execution: The callback function provided to watchEffect runs immediately upon component mounting and then re-runs whenever any of its automatically tracked dependencies change.
- No Access to Old Values: The watchEffect callback only provides access to the current values of the reactive dependencies, not their previous values.
- Conciseness: watchEffect can lead to more concise code when the side effect naturally depends on multiple reactive values within its scope.

```jsx
watch(stateRef, (newValue, oldValue) => {
  // watch works directly on a ref
})

watchEffect(() => {
  /* executed synchronously upon reactive data change */
  stateRef
})
```
