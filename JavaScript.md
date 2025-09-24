### Passing default configuration options in json
```js
function filter(
	array,
	{
		filterNull = true, // Setting default values if not provided
		filterUndefined = true,
		filterZero = false,
		filterEmptyString = false,
	} = {},
) {
	let newArray = []
	for (let index = 0; index < array.length; index++) {
		const element = array[index]
		if (
			(filterNull && element === null) ||
			(filterUndefined && element === undefined) ||
			(filterZero && element === 0) ||
			(filterEmptyString && element === '')
		) {
			continue
		}

		newArray[newArray.length] = element
	}
	return newArray
}

filter([0, 1, undefined, 2, null, 3, 'four', ''])
// [0, 1, 2, 3, 'four', '']

filter([0, 1, undefined, 2, null, 3, 'four', ''], { filterNull: false })
// [0, 1, 2, null, 3, 'four', '']

filter([0, 1, undefined, 2, null, 3, 'four', ''], { filterUndefined: false })
// [0, 1, 2, undefined, 3, 'four', '']

filter([0, 1, undefined, 2, null, 3, 'four', ''], { filterZero: true })
// [1, 2, 3, 'four', '']

filter([0, 1, undefined, 2, null, 3, 'four', ''], { filterEmptyString: true })
// [0, 1, 2, 3, 'four']
```

### Object loop

```js
Object.keys(myObject).forEach(key => {
  console.log(`${key}: ${myObject[key]}`);
});

Object.entries(myObject).forEach(([key, value]) => {
  console.log(`${key}: ${value}`);
});
```

### Validate only alphanumerics and space

```js
/^[\w\s]+$/.test(value);
```

## Email validation

```js
    const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
	const basicEmail = /^[\w]+@[\w]+\.[a-z]{2,3}$/;
```

## Validate date future

```js
	const today = new Date();
	const joiningDate = new Date('2025-09-23 00:00:00');

	today.setHours(0, 0, 0, 0);

	return today >= joiningDate;
```
