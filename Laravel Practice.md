- Create a Model
    ```
    php artisan make:model -fms Category
    -f, --factory
    -m, --migration
    -s, --seed
    ```
- Files generated
  - app/Models/Category.php
  - database/migrations/2025_09_11_192436_create_categories_table.php => Add the columns in up()
  - database/factories/CategoryFactory.php => Add attributes in definition()
  - database/seeders/CategorySeeder.php => use the Category::factory()->count(10)->create() in run()
  - database/seeders/DatabaseSeeder.php => use the class in $this->call([CategorySeeder::class]) in run()
- Create the UserSeeder
  ```
  php artisan make:seeder UserSeeder
  ```
- Run the migration and seed
  ```
  php artisan migrate:fresh
  php artisan db:seed
  ```
- Create an API routes file and install Laravel Sanctum
  ```
  php artisan install:api
  ```
- Files generated/updated
  - composer.json => Add laravel/sanctum
  - bootstrap/app.php => Add api to Application::configure()->withRouting([api: ...])
  - config/sanctum.php => Sanctum configuration file
  - database/migrations/2025_09_11_200256_create_personal_access_tokens_table.php => personal_access_tokens table
  - routes/api.php => Api routes definition
- Create Model with migration, seeder, factory, policy, resource controller, form request and test
  ```
  php artisan make:model -a --api --pest Book
  ```
- Files generated
  - app/Models/Book.php
  - database/migrations/2025_09_11_201530_create_books_table.php => foreignIdFor(Category::class)
  - database/factories/BookFactory.php
  - database/seeders/BookSeeder.php
  - app/Http/Controllers/BookController.php => api Route::apiResource('books', BookController::class)
  - app/Http/Requests/StoreBookRequest.php => validation exists:categories,id unique:books
  - app/Http/Requests/UpdateBookRequest.php => validation Rule::unique('books')->ignore($this->route('book'))
  - tests/Feature/Models/BookTest.php
  - tests/Feature/Http/Controllers/BookControllerTest.php
  - app/Policies/BookPolicy.php
- Create a invokable controller
  ```
  php artisan make:controller -i Api/v1/BookSearchController
  ```
- Prepare for pest testing
  ```
  composer remove phpunit/phpunit
  composer require pestphp/pest --dev --with-all-dependencies
  ./vendor/bin/pest --init

  ```
- Authentication
  ```
  php artisan make:controller Api/v1/AuthController --resource
  ```
  - Auth::once($request->only(['email', 'password']))
  - Auth::user()->createToken('token')
  - Auth::user()->currentAccessToken()->delete()
- Authorization
  - Gate::define('update-post', [PostPolicy::class, 'update']);
  - App\Policies\BookPolicy
  - return $user->tokenCanAny(['books-admin', 'books-visitor', '*']);
  - public function tokenCanAny(array $abilities) : bool
    - return $this->accessToken && array_intersect($abilities, $this->accessToken->abilities);
  - Gate::authorize('view', $book);
  - Tests
    - Sanctum::actingAs($user);
    - $user->createToken('token', ['books-admin']);
    - $user->withAccessToken($user->tokens->first());
    - $user = User::factory()->create();
    - $user->createToken('token', ['guest']);
    - $user->withAccessToken($user->tokens->first());
    - Auth::setUser($user);
- Api Documentation
  - composer require dedoc/scramble
  - /docs/api
- Resource
  ```
  php artisan make:resource BookResource
  ```
  - return new BookResource($book);
  - return BookResource::collection(Book::paginate());
  - return (new BookResource($book))->response()->setStatusCode(Response::HTTP_CREATED);
- Queue
  - QUEUE_CONNECTION=database
  ```
  php artisan make:queue-table
  php artisan make:queue-failed-table
  php artisan migrate
  php artisan make:job BookJob --pest
  php artisan queue:work -v
  php artisan queue:listen -v
  php artisan queue:restart
  php artisan queue:failed
  php artisan queue:retry all
  php artisan queue:flush
  php artisan queue:prune-failed
  ```
- Mail
  ```
  php artisan make:mail BookDeleted --pest --markdown=mail.book-deleted
  php artisan vendor:publish --tag=laravel-mail
  php artisan make:notifications-table
  ```
  - App\Mail\BookCreated => content
  - resources/views/mail/book-created.blade.php
  - Mail::to(Auth::user())->send(new BookDeleted($book));
  - Mail::to($request->user())->queue((new BookCreated($book))->afterCommit());
  - return (new BookCreated(Book::first()))->render();
  - Mail::fake();
  - Mail::assertSent(BookDeleted::class);
  - Mail::assertQueued(BookCreated::class);
- Notifications
  - https://laravel-notification-channels.com/
  ```
  php artisan make:notification BookUpdated --markdown=notification.book-updated --pest
  php artisan vendor:publish --tag=laravel-notifications
  ```
  - app/Notifications/BookUpdated.php
    - via() => ['mail'] // mail, database, broadcast, vonage, and slack
  - implements ShouldQueue
  - __construct() => $this->afterCommit();
  - to*Mail*
  - routeNotificationFor*Mail*
  -
- Broadcast
  - Laravel Echo => Echo.private('App.Models.User.' + userId)
  - import { useEchoNotification } from "@laravel/echo-react/vue";
