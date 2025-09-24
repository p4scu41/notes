### Resetting state with a key
  - You’ll often encounter the key attribute when rendering lists. However, it also serves another purpose.
  - You can use keys to make React distinguish between any components.
  - You can reset a component’s state by passing a different key to a component.
  - Resetting state with a key is particularly useful when dealing with forms.
  - This ensures that the component will be recreated from scratch, including any state in the tree below it. React will also re-create the DOM elements instead of reusing them.

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

// useFormStateData.js
// The inputs should have the "name" attribute
const useFormStateData = (defaultValue) => {
  const [formData, setFormData] = useState(defaultValue);

  const handleChange = (event) => {
    const { name, value } = event.target;

    setFormData((data) => ({ ...data, [name]: value }));
  };

  return { formData, setFormData, handleChange };
};

export function Form() {
  const { formData, handleChange } = useFormStateData({
    firstName: "Mary",
    lastName: "Poppins",
  });

  return (
    <>
      <label>
        First name:
        <input
          name="firstName"
          value={formData.firstName}
          onChange={handleChange}
        />
      </label>
      <label>
        Last name:
        <input
          name="lastName"
          value={formData.lastName}
          onChange={handleChange}
        />
      </label>
      <p>
        <b>
          Good morning, {formData.firstName} {formData.lastName}.
        </b>
      </p>
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

    // Inputs must have name property
    const formData = new FormData(event.target);
    const data = Object.fromEntries(formData.entries());
    event.target.reset();

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

// It must be pure, should take the state and action as arguments, and should return the next state.
// State is read-only. Don’t modify any objects or arrays in state:
// Instead, always return new objects from your reducer
function reducer(state, action) {
  switch (action.type) {
    case 'incremented_age': {
      return { // Make sure that every case branch copies all of the existing fields
        ...state,
        name: state.name,
        age: state.age + 1
      };
    }
    case 'changed_name': {
      return {
        ...state,
        name: action.nextName,
        age: state.age
      };
    }
  }

  console.warn('Unknown action: ' + action.type);

  // If the new value is identical to the current state, as determined by an Object.is comparison,
  // React will skip re-rendering the component and its children.
  return state;
}

const initialState = { name: 'Taylor', age: 42 };

export default function Form() {
  const [state, dispatch] = useReducer(reducer, initialState);

  function handleButtonClick() {
    // only updates the state variable for the next render.
    // If you read the state variable after calling the dispatch function, you will still get the old value
    // React batches state updates. It updates the screen after all the event handlers have run
    // By convention, it’s common to pass objects with a type property identifying the action
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

### Context

```jsx
// --- LevelContext.js
import { createContext } from 'react';

// The only argument to createContext is the default value
// The default value is only used if there is no matching provider above at all.
export const LevelContext = createContext(1);

// --- Heading.js
import { useContext } from 'react';
import { LevelContext } from './LevelContext.js';

export default function Heading({ children }) {
  // returns the context value for the calling component.
  // It is determined as the value passed to the closest LevelContext.Provider above the calling component in the tree.
  // If there is no such provider, then the returned value will be the defaultValue you have passed to createContext.
  // The returned value is always up-to-date. React automatically re-renders components that read some context if it changes.
  const level = useContext(LevelContext);
  // ...
}

// --- Section.js
import { LevelContext } from './LevelContext.js';

export default function Section({ children }) {
  // context lets you read information from a component above
  // always looks for the closest provider above the component that calls it.
  // It searches upwards and does not consider providers in the component from which you’re calling useContext().
  const level = useContext(LevelContext);

  // React automatically re-renders all the children that use a particular context
  // starting from the provider that receives a different value.
  // You must pass value prop
  return (
    <section className="section">
      <LevelContext.Provider value={level + 1}>
        {children}
      </LevelContext.Provider>
    </section>
  );
}

// --- App.js
import Heading from './Heading.js';
import Section from './Section.js';

export default function Page() {
  return (
    <Section>
      <Heading>Title</Heading>
      <Section>
        <Heading>Heading</Heading>
        <Heading>Heading</Heading>
        <Heading>Heading</Heading>
        <Section>
          <Heading>Sub-heading</Heading>
          <Heading>Sub-heading</Heading>
          <Heading>Sub-heading</Heading>
        </Section>
      </Section>
    </Section>
  );
}

// Performance optimization
import { useCallback, useMemo } from 'react';

function MyApp() {
  const [currentUser, setCurrentUser] = useState(null);

  const login = useCallback((response) => {
    storeCredentials(response.credentials);
    setCurrentUser(response.user);
  }, []);

  const contextValue = useMemo(() => ({ // Ensure having the same object unless currentUser or login change
    currentUser,
    login
  }), [currentUser, login]);

  // even if MyApp needs to re-render, the components calling useContext(AuthContext) won’t need to re-render unless currentUser has changed.
  return (
    <AuthContext.Provider value={contextValue}>
      <Page />
    </AuthContext.Provider>
  );
}
```

### Scaling Up with Reducer and Context
```jsx
// --- App.js
import AddTask from './AddTask.js';
import TaskList from './TaskList.js';
import { TasksProvider } from './TasksContext.js';

export default function TaskApp() {
  return (
    <TasksProvider>
      <h1>Day off in Kyoto</h1>
      <AddTask />
      <TaskList />
    </TasksProvider>
  );
}

// --- TasksContext.js
import { createContext, useContext, useReducer } from 'react';

const TasksContext = createContext(null);

const TasksDispatchContext = createContext(null);

export function TasksProvider({ children }) {
  const [tasks, dispatch] = useReducer(
    tasksReducer,
    initialTasks
  );

  return (
    <TasksContext.Provider value={tasks}>
      <TasksDispatchContext.Provider value={dispatch}>
        {children}
      </TasksDispatchContext.Provider>
    </TasksContext.Provider>
  );
}

export function useTasks() {
  return useContext(TasksContext);
}

export function useTasksDispatch() {
  return useContext(TasksDispatchContext);
}

function tasksReducer(tasks, action) {
  switch (action.type) {
    case 'added': {
      return [...tasks, {
        id: action.id,
        text: action.text,
        done: false
      }];
    }
    case 'changed': {
      return tasks.map(t => {
        if (t.id === action.task.id) {
          return action.task;
        } else {
          return t;
        }
      });
    }
    case 'deleted': {
      return tasks.filter(t => t.id !== action.id);
    }
    default: {
      throw Error('Unknown action: ' + action.type);
    }
  }
}

const initialTasks = [
  { id: 0, text: 'Philosopher’s Path', done: true },
  { id: 1, text: 'Visit the temple', done: false },
  { id: 2, text: 'Drink matcha', done: false }
];

// --- AddTask.js
import { useState } from 'react';
import { useTasksDispatch } from './TasksContext.js';

export default function AddTask() {
  const [text, setText] = useState('');
  const dispatch = useTasksDispatch();

  return (
    <>
      <input
        placeholder="Add task"
        value={text}
        onChange={e => setText(e.target.value)}
      />
      <button onClick={() => {
        setText('');
        dispatch({
          type: 'added',
          id: nextId++,
          text: text,
        });
      }}>Add</button>
    </>
  );
}

let nextId = 3;

// --- TaskList.js
import { useState } from 'react';
import { useTasks, useTasksDispatch } from './TasksContext.js';

export default function TaskList() {
  const tasks = useTasks();

  return (
    <ul>
      {tasks.map(task => (
        <li key={task.id}>
          <Task task={task} />
        </li>
      ))}
    </ul>
  );
}

function Task({ task }) {
  const [isEditing, setIsEditing] = useState(false);
  const dispatch = useTasksDispatch();
  let taskContent;
  if (isEditing) {
    taskContent = (
      <>
        <input
          value={task.text}
          onChange={e => {
            dispatch({
              type: 'changed',
              task: {
                ...task,
                text: e.target.value
              }
            });
          }} />
        <button onClick={() => setIsEditing(false)}>
          Save
        </button>
      </>
    );
  } else {
    taskContent = (
      <>
        {task.text}
        <button onClick={() => setIsEditing(true)}>
          Edit
        </button>
      </>
    );
  }
  return (
    <label>
      <input
        type="checkbox"
        checked={task.done}
        onChange={e => {
          dispatch({
            type: 'changed',
            task: {
              ...task,
              done: e.target.checked
            }
          });
        }}
      />
      {taskContent}
      <button onClick={() => {
        dispatch({
          type: 'deleted',
          id: task.id
        });
      }}>
        Delete
      </button>
    </label>
  );
}
```

## Strategics

### Compound Components
```jsx
function App() {
	return (
		<Menu>
			<MenuButton>
				Actions <span aria-hidden>▾</span>
			</MenuButton>
			<MenuList>
				<MenuItem onSelect={() => alert('Download')}>Download</MenuItem>
				<MenuItem onSelect={() => alert('Copy')}>Create a Copy</MenuItem>
				<MenuItem onSelect={() => alert('Delete')}>Delete</MenuItem>
			</MenuList>
		</Menu>
	)
}
```

### Render Props
```jsx
<List
	// ... some props
	rowRenderer={({ key, index, style }) => (
		<div
		// ... some props
		/>
	)}
/>
```

###
```jsx
// returns a function which calls all the given functions
const callAll =
	(...fns) =>
	(...args) =>
		fns.forEach((fn) => fn && fn(...args))

function useToggle(initialOn = false) {
	const [on, setOn] = useState(initialOn)
	const toggle = () => setOn(!on)

	return { on, toggle }
}

function useToggleWithPropGetter(initialOn) {
	const { on, toggle } = useToggle(initialOn)

	const getTogglerProps = (props = {}) => ({
		'aria-expanded': on,
		tabIndex: 0,
		...props,
		onClick: callAll(props.onClick, toggle),
	})

	return { on, toggle, getTogglerProps }
}

function App() {
	const { on, getTogglerProps } = useToggle()
	return <button {...getTogglerProps()}>{on ? 'on' : 'off'}</button>
}
```

### Passing Children as prop to improve re-renders
```js
const cache = {};

const Child = () => {
  console.log("  > Child");

  return {
    type: "Child",
    props: "Child Props",
    children: [],
  };
};

const Parent = (childInstance = null) => {
  console.log("* Parent");

  const childObj = childInstance || Child();

  if (cache[childObj.type] !== childObj) {
    console.log("Render Child");
  } else {
    console.log("Same Child");
  }

  cache.Child = childObj;

  return {
    type: "Parent",
    props: "Parent Props",
    children: [childObj],
  };
};

console.log(" --- Rendering Child inside Parent ---");
console.log(Parent());
console.log(Parent());
console.log(Parent());

console.log(" --- Passing Child as Parent prop ---");
const childObj = Child();
console.log(childObj);
console.log(Parent(childObj));
console.log(Parent(childObj));
console.log(Parent(childObj));
```


### Debounce

```jsx
const Search = () => {
  const [query, setQuery] = useState("");
  const [searchTerm, setSearchTerm] = useState("");

  useEffect(() => {
    const timeoutId = setTimeout(() => {
      setSearchTerm(query);
    }, 500);

    return () => clearTimeout(timeoutId);
  }, [query]);

  return (
    <div>
      <input
        type="text"
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="Search..."
      />
      <p>Results for: {searchTerm}</p>
    </div>
  );
};

const useDebounceState = (defaultValue, delay) => {
  const [value, setValue] = useState(defaultValue);
  const [debouncedValue, setDebouncedValue] = useState(defaultValue);

  useEffect(() => {
    const timeoutId = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    return () => {
      clearTimeout(timeoutId);
    };
  }, [value, delay]);

  return [value, setValue, debouncedValue];
};

const [value, setValue, debouncedValue] = useDebounceState("", 500);
```

### Fetch chained information

Database using json-server
 > json-server companies_db.json
```json
{
  "companies": [
    {
      "id": "1",
      "name": "Google",
      "locations": ["1", "2"]
    },
    {
      "id": "2",
      "name": "Amazon",
      "locations": ["3", "4"]
    }
  ],
  "locations": [
    {
      "id": "1",
      "name": "California"
    },
    {
      "id": "2",
      "name": "New York"
    },
    {
      "id": "3",
      "name": "Washington"
    }
  ]
}
```

```js
// --- Services --- Return Promise

function getCompanies() {
  return fetch("http://localhost:3000/companies")
    .then((response) => response.json());
}

function getLocation(locationId) {
  return fetch(`http://localhost:3000/locations/${locationId}`)
    .then((response) => response.json());
}

// --- Utils ---

/*
  { status: 'fulfilled', value: Response }
  { status: 'rejected', reason: Error }
*/
const filterFulfilledPromises = (results) => {
  return results
    .filter((result) => result.status === "fulfilled")
    .map((result) => result.value);
};

// --- Main logic ---

// This returns a Promise because it is using async
const fetchLocationsByCompany = async (company) => {
  /*
  Promise.allSettled()
    - Takes an iterable of promises as input and returns a single Promise.
    - This returned promise fulfills when all of the input's promises settle
      with an array of objects that describe the outcome of each promise.
  */
  const locationsData = await Promise.allSettled(
    company.locations.map(
      (locationId) => getLocation(locationId)
    )
  );

  return { ...company, locations: filterFulfilledPromises(locationsData) };
};

getCompanies()
  .then((companies) => {
    return companies.map(fetchLocationsByCompany);
  }).then((allData) => {
    // It requires to resolve "allData" because fetchLocationsByCompany return a Promise
    Promise.allSettled(allData)
      .then((results) => {
        const companiesWithLocations = filterFulfilledPromises(results);

        console.log("companiesWithLocations", companiesWithLocations);
      });
  });
```
