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

All these methods take an iterable of promises and return a new promise. Note that JavaScript is single-threaded by nature, so at a given instant, only one task will be executing, although control can shift between different promises, making execution of the promises appear concurrent. Parallel execution in JavaScript can only be achieved through worker threads.

- Promise.all(): Fulfills when all of the promises fulfill; rejects when any of the promises rejects.

- Promise.allSettled(): Fulfills when all promises settle.

- Promise.any(): Fulfills when any of the promises fulfills; rejects when all of the promises reject.

- Promise.race(): Settles when any of the promises settles. In other words, fulfills when any of the promises fulfills; rejects when any of the promises rejects.

```js
// If one of the promises in the array rejects, Promise.all() immediately rejects the returned promise.
// The other operations continue to run, but their outcomes are not available via the return value of Promise.all().
// This may cause unexpected state or behavior.
// Promise.allSettled() is another composition tool that ensures all operations are complete before resolving.
// These methods all run promises concurrently — a sequence of promises are started simultaneously and do not wait for each other.

Promise.all([func1(), func2(), func3()]).then(([result1, result2, result3]) => {
  // use result1, result2 and result3
});


// Sequential composition is possible using some clever JavaScript:
[func1, func2, func3]
  .reduce((p, f) => p.then(f), Promise.resolve())
  .then((result3) => {
    /* use result3 */
  });

// In this example, we reduce an array of asynchronous functions down to a promise chain.
// The code above is equivalent to:
Promise.resolve()
  .then(func1)
  .then(func2)
  .then(func3)
  .then((result3) => {
    /* use result3 */
  });

// This can be made into a reusable compose function, which is common in functional programming:
const applyAsync = (acc, val) => acc.then(val);

const composeAsync =
  (...funcs) =>
  (x) =>
    funcs.reduce(applyAsync, Promise.resolve(x));

// The composeAsync() function accepts any number of functions as arguments and
// returns a new function that accepts an initial value to be passed through the composition pipeline:
const transformData = composeAsync(func1, func2, func3);
const result3 = transformData(data);

// Sequential composition can also be done more succinctly with async/await:
let result;
for (const f of [func1, func2, func3]) {
  result = await f(result);
}
/* use last result (i.e. result3) */
// it's always better to run promises concurrently so that they don't unnecessarily block each other
// unless one promise's execution depends on another's result.

// Promise itself has no first-class protocol for cancellation,
// but you may be able to directly cancel the underlying asynchronous operation,
// typically using AbortController.

// Functions passed to then() will never be called synchronously, even with an already-resolved promise:
// Instead of running immediately, the passed-in function is put on a microtask queue, which means it runs later
// (only after the function which created it exits, and when the JavaScript execution stack is empty),
// just before control is returned to the event loop; i.e., pretty soon:

const wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

wait(0).then(() => console.log(4));
Promise.resolve()
  .then(() => console.log(2))
  .then(() => console.log(3));
console.log(1); // 1, 2, 3, 4

// Promise callbacks are handled as a microtask
// whereas setTimeout() callbacks are handled as task queues.

const promise = new Promise((resolve, reject) => {
  console.log("Promise callback");
  resolve();
}).then((result) => {
  console.log("Promise callback (.then)");
});

setTimeout(() => {
  console.log("event-loop cycle: Promise (fulfilled)", promise);
}, 0);

console.log("Promise (pending)", promise);

// The code above will output:

// Promise callback
// Promise (pending) Promise {<pending>}
// Promise callback (.then)
// event-loop cycle: Promise (fulfilled) Promise {<fulfilled>}

// When you return something from a then() callback, it's a bit magic.
// If you return a value, the next then() is called with that value.
// However, if you return something promise-like, the next then() waits on it,
// and is only called when that promise settles (succeeds/fails)

// The spec also uses the term thenable to describe an object that is promise-like, in that it has a then method.

// https://web.dev/articles/promises

var storyPromise;

function getChapter(i) {
  storyPromise = storyPromise || getJSON('story.json');

  return storyPromise.then(function(story) {
    return getJSON(story.chapterUrls[i]);
  })
}

// and using it is simple:
getChapter(0).then(function(chapter) {
  console.log(chapter);
  return getChapter(1);
}).then(function(chapter) {
  console.log(chapter);
})
// We don't download story.json until getChapter is called, but the next time(s) getChapter is called we reuse the story promise, so story.json is only fetched once. Yay Promises!

// Start off with a promise that always resolves
var sequence = Promise.resolve();

// Loop through our chapter urls
story.chapterUrls.forEach(function(chapterUrl) {
  // Add these actions to the end of the sequence
  sequence = sequence.then(function() {
    return getJSON(chapterUrl);
  }).then(function(chapter) {
    addHtmlToPage(chapter.html);
  });
})

// We can tidy up the above code using array.reduce:

// Loop through our chapter urls
story.chapterUrls.reduce(function(sequence, chapterUrl) {
  // Add these actions to the end of the sequence
  return sequence.then(function() {
    return getJSON(chapterUrl);
  }).then(function(chapter) {
    addHtmlToPage(chapter.html);
  });
}, Promise.resolve())

// Let's put it all together:

getJSON('story.json').then(function(story) {
  addHtmlToPage(story.heading);

  return story.chapterUrls.reduce(function(sequence, chapterUrl) {
    // Once the last chapter's promise is done…
    return sequence.then(function() {
      // …fetch the next chapter
      return getJSON(chapterUrl);
    }).then(function(chapter) {
      // and add it to the page
      addHtmlToPage(chapter.html);
    });
  }, Promise.resolve());
}).then(function() {
  // And we're all done!
  addTextToPage("All done");
}).catch(function(err) {
  // Catch any error that happened along the way
  addTextToPage("Argh, broken: " + err.message);
}).then(function() {
  // Always hide the spinner
  document.querySelector('.spinner').style.display = 'none';
})

// Promise.all takes an array of promises and creates a promise that fulfills when all of them successfully complete.
// You get an array of results (whatever the promises fulfilled to) in the same order as the promises you passed in.

getJSON('story.json').then(function(story) {
  addHtmlToPage(story.heading);

  // Take an array of promises and wait on them all
  return Promise.all(
    // Map our array of chapter urls to
    // an array of chapter json promises
    story.chapterUrls.map(getJSON)
  );
}).then(function(chapters) {
  // Now we have the chapters jsons in order! Loop through…
  chapters.forEach(function(chapter) {
    // …and add to the page
    addHtmlToPage(chapter.html);
  });
  addTextToPage("All done");
}).catch(function(err) {
  // catch any error that happened so far
  addTextToPage("Argh, broken: " + err.message);
}).then(function() {
  document.querySelector('.spinner').style.display = 'none';
})

// However, we can still improve perceived performance. When chapter one arrives we should add it to the page. This lets the user start reading before the rest of the chapters have arrived. When chapter three arrives, we wouldn't add it to the page because the user may not realize chapter two is missing.
// To do this, we fetch JSON for all our chapters at the same time, then create a sequence to add them to the document:

getJSON('story.json')
.then(function(story) {
  addHtmlToPage(story.heading);

  // Map our array of chapter urls to
  // an array of chapter json promises.
  // This makes sure they all download in parallel.
  return story.chapterUrls.map(getJSON)
    .reduce(function(sequence, chapterPromise) {
      // Use reduce to chain the promises together,
      // adding content to the page for each chapter
      return sequence
      .then(function() {
        // Wait for everything in the sequence so far,
        // then wait for this chapter to arrive.
        return chapterPromise;
      }).then(function(chapter) {
        addHtmlToPage(chapter.html);
      });
    }, Promise.resolve());
}).then(function() {
  addTextToPage("All done");
}).catch(function(err) {
  // catch any error that happened along the way
  addTextToPage("Argh, broken: " + err.message);
}).then(function() {
  document.querySelector('.spinner').style.display = 'none';
})
```

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

### Async/await functions

```js
async function myFirstAsyncFunction() {
  try {
    const fulfilledValue = await promise;
  } catch (rejectedValue) {
    // …
  }
}
```

If you use the async keyword before a function definition, you can then use await within the function. When you await a promise, the function is paused in a non-blocking way until the promise settles. If the promise fulfills, you get the value back. If the promise rejects, the rejected value is thrown.

Say you want to fetch a URL and log the response as text. Here's how it looks using promises:

```js
function logFetch(url) {
  return fetch(url)
    .then((response) => response.text())
    .then((text) => {
      console.log(text);
    })
    .catch((err) => {
      console.error('fetch failed', err);
    });
}
```

And here's the same thing using async functions:

```js
async function logFetch(url) {
  try {
    const response = await fetch(url);
    console.log(await response.text());
  } catch (err) {
    console.log('fetch failed', err);
  }
}
```

Note: Anything you **await** is passed through Promise.resolve(), so you can safely await non-platform promises, such as those created by promise polyfills.

Async functions **always return a promise**, whether you use await or not. That promise resolves with whatever the async function returns, or rejects with whatever the async function throws.

```js
// map some URLs to json-promises
const jsonPromises = urls.map(async (url) => {
  const response = await fetch(url);
  return response.json();
});
```

Note: The array.map(func) doesn't care that I gave it an async function. It just sees it as a function that returns a promise. It won't wait for the first function to complete before calling the second.

Although you're writing code that looks synchronous, ensure you don't miss the opportunity to do things in parallel.

```js
async function series() {
  await wait(500); // Wait 500ms…
  await wait(500); // …then wait another 500ms.
  return 'done!';
}
```

The above takes 1000ms to complete, whereas:

```js
async function parallel() {
  const wait1 = wait(500); // Start a 500ms timer asynchronously…
  const wait2 = wait(500); // …meaning this timer happens in parallel.
  await Promise.all([wait1, wait2]); // Wait for both timers in parallel.
  return 'done!';
}
```

The above takes 500ms to complete, because both waits happen at the same time. Let's look at a practical example.

```js
function markHandled(...promises) {
  Promise.allSettled(promises);
}

async function logInOrder(urls) {
  // fetch all the URLs in parallel
  const textPromises = urls.map(async (url) => {
    const response = await fetch(url);
    return response.text();
  });

  markHandled(...textPromises);

  // log them in sequence
  for (const textPromise of textPromises) {
    console.log(await textPromise);
  }
}
```

**Key point**: markHandled is used to avoid "unhandled promise rejections". If a promise rejects, and it was never given a rejection handler (for example, via .catch(handler)), it's known as an "unhandled rejection". These are logged to the console, and also trigger a global event. The gotcha when handling a bunch of promises in sequence, is if one of them rejects, the function ends and the remaining promises are never handled. markHandled is used to prevent this, by attaching rejection handlers to all of the promises.

However, as soon as there's one await, the function becomes asynchronous, and execution of following statements is deferred to the next tick.

```js
async function foo(name) {
  console.log(name, "start");
  await console.log(name, "middle");
  console.log(name, "end");
}

foo("First");
foo("Second");

// First start
// First middle
// Second start
// Second middle
// First end
// Second end
```

This corresponds to:

```js
function foo(name) {
  return new Promise((resolve) => {
    console.log(name, "start");
    resolve(console.log(name, "middle"));
  }).then(() => {
    console.log(name, "end");
  });
}
```
