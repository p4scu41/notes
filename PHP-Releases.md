### PHP 8.1

- Allow unpacking arrays with string keys

  ```php
    $attributes = ['title' => 'The Title', 'author' => 'The Author'];
    $additional = ['category_id' => 1];

    $all = [...$attributes, ...$additional];
  ```

- Never Return Type

  ```php
  function visit($url): never
  {
    header(`Location: $url`);
    exit;
  }
  ```

- Constructor Property Promotion supports objects

  ```php
  class Signup
  {
    public function __construct(
      private Newsletter $newsletter = new MailChimpNewsletter() // New
    ) {}

    public function perform()
    {
      $this->newsletter->subscribe();
    }
  }
  ```

- Read-Only Properties

  ```php
  class Project
  {
    public function __construct(public readonly string $uid)
    {
    }
  }
  ```

- Enums

  ```php
  enum PostStatus
  {
    case DRAFT = 'Draft';
    case PUBLISHED = 'Published';

    public function icon(): string
    {
      return match($this) {
        self::DRAFT => '...',
        self::PUBLISHED => '✓',
      };
    }
  }

  echo PostStatus::DRAFT->name;  // Outputs: DRAFT
  echo PostStatus::DRAFT->value; // Outputs: Draft

  $status = PostStatus::PUBLISHED;
  echo $status->icon(); // Outputs: ✓
  ```

---

### PHP 8

- The Nullsafe Operator

  ```php
  echo $user->profile()?->employment; // New
  // Chaining with Coalescing Operator
  echo $user?->profile()?->employment ?? 'Not provided';
  ```

- Match Expressions

  ```php
  switch (get_class($object)) {
    case Conversation::class:
      $type = 'started_conversation';
      break;
    case Reply::class:
      $type = 'replied_to_conversation';
      break;
    case Comment::class:
      $type = 'commented_on_lesson';
      break;
    default:
      $type = 'unknown';
  }

  $type = match (get_class($object)) { // New
    Conversation::class => 'started_conversation',
    Reply::class => 'replied_to_conversation',
    Comment::class => 'commented_on_lesson',
    default => 'unknown',
  };
  ```

- Constructor Property Promotion

  ```php
  class User
  {
    protected string $name;

    public function __construct(string $name) {
      $this->name = $name;
    }
  }

  class User {
    public function __construct(protected string $name = 'Not Provided') {} // New
  }
  ```

  - Default values are limited to primitives; you cannot use expressions
  - If you need extra validation or logic, you can still add a constructor body
  - You can mix promoted properties with traditional property declarations and assignments if needed

- $object::class

  ```php
  $user = new User();
  echo $user::class;
  ```

- Named Parameters

  ```php
  class Invoice
  {
    public function __construct(
      public string $description,
      public float $total,
      public DateTime $date,
      public bool $paid
    ) {}
  }

  $invoice = new Invoice(
    'Customer installation',
    100.00,
    new DateTime(),
    true
  );

  $invoice = new Invoice( // New
    paid: true,
    date: new DateTime(),
    total: 100.00,
    description: 'Customer installation'
  );
  ```

  - The order of arguments is irrelevant
  - Couples your code to the parameter names

- New String Helpers

  ```php
  str_starts_with('inv_12345', 'inv_'); // true
  str_ends_with('12345_cha', '_cha'); // true
  str_contains('https://example.com/page?foo=bar', '?'); // true
  ```

- Weak Maps

  ```php
  $store = new WeakMap();
  $object = new \stdClass();
  $store[$object] = 'foobar';
  ```

  - Allows to associate data with objects, the "keys" must be objects
  - Enable garbage collection, when you unset the object reference, the key-value pair is automatically removed from the map

- Union and Pseudo Types

  ```php
  public function makeFriend(User|string $userOrEmail)
  {
    if ($userOrEmail instanceof User) {
      // Update pivot table to make friends
    } else {
      // Dispatch invitation email to $userOrEmail
    }
  }

  public function cancelSubscription(bool|DateTime|string $when = false) {
    // ...
  }

  declare(strict_types=1); // enforce exact type matching and avoid implicit coercion, should be the first line of the PHP file


  public function example(mixed $value) { // mixed represents any type
    // $value can be any type
  }
  ```

- Attributes

  ```php
  // a.php
  namespace MyExample;

  use Attribute;

  #[Attribute]
  class MyAttribute
  {
    const VALUE = 'value';

    private $value;

    public function __construct($value = null)
    {
      $this->value = $value;
    }

  }

  // b.php
  namespace Another;

  use MyExample\MyAttribute;

  #[MyAttribute]
  #[\MyExample\MyAttribute]
  #[MyAttribute(1234)]
  #[MyAttribute(value: 1234)]
  #[MyAttribute(MyAttribute::VALUE)]
  #[MyAttribute(array("key" => "value"))]
  #[MyAttribute(100 + 200)]
  class Thing
  {
  }

  #[MyAttribute(1234), MyAttribute(5678)]
  class AnotherThing
  {
  }
  ````

- Allows declaring meta-data for functions, classes, properties, and parameters
- Attributes map to PHP class names (declared with an Attribute itself), and they can be fetched with Reflection

---

### PHP 7.4

- Arrow Functions

  ```php
  $books->each(fn($book) => $book->title = ucwords($book->title));
  ````

- Support only single expressions; multiline are not allowed
- The "return" keyword is implicit
- They automatically capture variables from the parent scope by value, so you don't need to use "use"

- Null Coalescing Assignment Operator

  ```php
  echo isset($_GET['name']) ? $_GET['name'] : 'not provided';
  echo $_GET['name'] ?? 'Not Provided'; // New

  $user = [
    'name' => [
      'last' => 'Doe',
    ],
  ];

  $user['name']['first'] = isset($user['name']['first']) ? $user['name']['first'] : 'Not Provided';
  $user['name']['first'] = $user['name']['first'] ?? 'Not Provided'; // New
  $user['name']['first'] ??= 'Joe'; // New
  ```

- Spread Operator Within Arrays

  ```php
  function add() {
    return array_sum(func_get_args());
  }

  echo add(2, 3, 4); // Outputs 9

  function add(int ...$numbers) { // New
    return array_sum($numbers);
  }

  var_dump(['foo', 'bar', ...['baz']]); // New

  $array1 = ['foo', 'bar'];
  $array2 = ['baz'];

  $combined = [...$array1, ...$array2]; // New

  function add(int $initial, int ...$numbers) {
    return array_sum([$initial, ...$numbers]);
  }

  $nums = [4, 3];
  echo add(3, ...$nums); // Outputs 10
  ```

  - Not allow unpacking arrays with string keys, will throw an error
    - Fatal error: Cannot unpack array with string keys

---

### PHP 7.1

- Symmetric Array Destructuring

  ```php
  [$title, $author] = ['The Title', 'The Author'];
  ['title' => $title, 'author' => $author] = ['title' => 'The Title', 'author' => 'The Author'];
  $books = [
    ['title' => 'The Title 1', 'author' => 'The Author 1'],
    ['title' => 'The Title 2', 'author' => 'The Author 2'],
  ];

  foreach ($books as ['title' => $title, 'author' => $author]) {
    // ...
  }
  ```

- Nullable and Void Types

  ```php
  class User
  {
    protected $age;

    public function age() : ?int
    {
      return $this->age;
    }

    public function subscribe(?callable $callback = null) : void
    {
      if ($callback) $callback();
    }
  }

  $age = (new User)->age();

  (new User)->subscribe(function () {
    // ...
  });
  ```

- Multi-Catch Exception Handling

  ```php
  class ChargeRejectedException extends Exception {}
  class NotEnoughFundsException extends Exception {}

  class User
  {
    public function subscribe()
    {
      throw new NotEnoughFundsException;
    }
  }

  try {
    $user->subscribe();
  } catch (ChargeRejectedException | NotEnoughFundsException $e) {
    var_dump('Failed');
  }
  ```

- Iterables

  ```php
  function dumpAll(iterable $items)
  {
    foreach($items as $item) {
      // ...
    }
  }

  dumpAll(['one', 'two', 'three']);
  ```
