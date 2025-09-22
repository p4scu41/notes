### Reusing Logic with Custom Hooks

```jsx
// useFormInput.js
import { useState } from 'react';

export function useFormInput(initialValue) {
  const [value, setValue] = useState(initialValue);

  function handleChange(e) {
    setValue(e.target.value);
  }

  const inputProps = {
    value: value,
    onChange: handleChange
  };

  return inputProps;
}

// App.js
import { useFormInput } from './useFormInput.js';

export default function Form() {
  const firstNameProps = useFormInput('Mary');
  const lastNameProps = useFormInput('Poppins');

  return (
    <>
      <label>
        First name:
        <input {...firstNameProps} />
      </label>
      <label>
        Last name:
        <input {...lastNameProps} />
      </label>
      <p><b>Good morning, {firstNameProps.value} {lastNameProps.value}.</b></p>
    </>
  );
}
```

### Fetch information

```jsx
function useData(url) {
  const [data, setData] = useState(null);

  useEffect(() => {
    if (url) {
      let active = true;

      fetch(url)
        .then(response => response.json())
        .then(json => {
          if (active) {
            setData(json);
          }
        });

      return () => {
        active = false;
      };
    }
  }, [url]);

  return data;
}
```

### Gather From data on submit

```js
const handleSubmit = (event) => {
    event.preventDefault();

    const formData = new FormData(event.target);
    const data = Object.fromEntries(formData.entries());

    console.log(data); // Contains all form field values
    // ... send data to backend
};
```

### useEffect and Race Conditions

- Using a Flag or AbortController

```jsx
import { useState, useEffect } from 'react';
import { fetchBio } from './api.js';

export default function PageUsingThen() {
  const [person, setPerson] = useState('Alice');
  const [bio, setBio] = useState(null);

  useEffect(() => {
    const controller = new AbortController();
    let active = true;

    setBio(null);

    fetchBio(person, {signal: controller.signal}).then(result => {
      if (active) {
        setBio(result);
      }
    });

    return () => {
      active = false;
      controller.abort
    }
  }, [person]);

  return (
    <>
      <select value={person} onChange={e => {
        setPerson(e.target.value);
      }}>
        <option value="Alice">Alice</option>
        <option value="Bob">Bob</option>
      </select>
      <hr />
      <p><i>{bio ?? 'Loading...'}</i></p>
    </>
  );
}

export default function PageUsingAsync() {
  const [person, setPerson] = useState('Alice');
  const [bio, setBio] = useState(null);

  useEffect(() => {
    const controller = new AbortController();

    async function startFetching() {
      setBio(null);

      try {
        const result = await fetchBio(person, {
          signal: controller.signal,
        });

        if (active) {
          setBio(result);
        }
      } catch (error) {
        if (error.name === 'AbortError') return; // Ignore abort error
        // Handle other errors
      }
    }

    let active = true;

    startFetching();

    return () => {
      active = false;
      controller.abort();
    }
  }, [person]);

  return (
    <>
      <select value={person} onChange={e => {
        setPerson(e.target.value);
      }}>
        <option value="Alice">Alice</option>
        <option value="Bob">Bob</option>
      </select>
      <hr />
      <p><i>{bio ?? 'Loading...'}</i></p>
    </>
  );
}
```

### Reducer

```jsx
import { useReducer } from 'react';

function reducer(state, action) {
  switch (action.type) {
    case 'incremented_age': {
      return {
        name: state.name,
        age: state.age + 1
      };
    }
    case 'changed_name': {
      return {
        name: action.nextName,
        age: state.age
      };
    }
  }
  throw Error('Unknown action: ' + action.type);
}

const initialState = { name: 'Taylor', age: 42 };

export default function Form() {
  const [state, dispatch] = useReducer(reducer, initialState);

  function handleButtonClick() {
    dispatch({ type: 'incremented_age' });
  }

  function handleInputChange(e) {
    dispatch({
      type: 'changed_name',
      nextName: e.target.value
    });
  }

  return (
    <>
      <input
        value={state.name}
        onChange={handleInputChange}
      />
      <button onClick={handleButtonClick}>
        Increment age
      </button>
      <p>Hello, {state.name}. You are {state.age}.</p>
    </>
  );
}

```
