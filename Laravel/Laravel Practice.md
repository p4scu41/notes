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
  tests/Pest.php => pest()->use(Illuminate\Foundation\Testing\RefreshDatabase::class)
  ```
- Authentication
  ```
  php artisan make:controller Api/v1/AuthController --resource
  ```
  ```php
  Auth::once($request->only(['email', 'password']))
  Auth::user()->createToken('token')
  Auth::user()->currentAccessToken()->delete()
  ```
- Authorization
  php artisan make:policy BookPolicy --model=Book
  ```php
  Gate::define('update-post', [PostPolicy::class, 'update']);
  App\Policies\BookPolicy
  return $user->tokenCanAny(['books-admin', 'books-visitor', '*']);
  public function tokenCanAny(array $abilities) : bool {
    return $this->accessToken && array_intersect($abilities, $this->accessToken->abilities);
  }
  - Gate::authorize('view', $book);
  ```
  - Tests
  ```php
    Sanctum::actingAs($user);
    $user->createToken('token', ['books-admin']);
    $user->withAccessToken($user->tokens->first());
    $user = User::factory()->create();
    $user->createToken('token', ['guest']);
    $user->withAccessToken($user->tokens->first());
    Auth::setUser($user);
  ```
- Api Documentation
  - composer require dedoc/scramble
  - /docs/api
- Resource
  ```
  php artisan make:resource BookResource
  ```
  ```php
  return new BookResource($book);
  return BookResource::collection(Book::paginate());
  return (new BookResource($book))->response()->setStatusCode(Response::HTTP_CREATED);
  ```
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
  ```php
  Mail::to(Auth::user())->send(new BookDeleted($book));
  Mail::to($request->user())->queue((new BookCreated($book))->afterCommit());
  return (new BookCreated(Book::first()))->render();
  Mail::fake();
  Mail::assertSent(BookDeleted::class);
  Mail::assertQueued(BookCreated::class);
  ```
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
- Event and Listener
  ```
  php artisan make:event BookRegistered
  php artisan make:listen BookUpdateInventory --event=BookRegistered --pest
  php artisan event:list
  php artisan event:cache
  php artisan event:clear
  ```
  - app/Events/BookRegistered.php
  - app/Listeners/BookUpdateInventory.php
  - implements Illuminate\Contracts\Queue\ShouldQueue
  - implements Illuminate\Contracts\Queue\ShouldQueueAfterCommit
  - use Illuminate\Queue\InteractsWithQueue
  - implements Illuminate\Contracts\Queue\ShouldBeEncrypted
  - implements Illuminate\Contracts\Events\ShouldDispatchAfterCommit
- Observer
  ```
  php artisan make:observer BookObserver --model=Book
  ```
  - app/Observers/BookObserver.php
  - #[\Illuminate\Database\Eloquent\Attributes\ObservedBy([\App\Observers\BookObserver::class])] // Add in the Model Class
- Broadcast
  - Laravel Echo => Echo.private('App.Models.User.' + userId)
  - import { useEchoNotification } from "@laravel/echo-react/vue";
- Middleware
  ```
  php artisan make:middleware LogRequestsToBook --pest
  ```
  - app/Http/Middleware/LogRequestsToBook.php
  - bootstrap/app.php => withMiddleware
- Command
  ```
  php artisan make:command SendEmails --pest
  ```
  - app/Console/Commands/SendEmails.php
  - implements Illuminate\Contracts\Console\PromptsForMissingInput;
- Cache
  ```php
  $value = Cache::get('key', 'default');
  $value = Cache::get('key', function () {
    return DB::table(/* ... */)->get();
  });
  Cache::has('key')
  Cache::add('key', 0, now()->addHours(4));
  $value = Cache::remember('users', $seconds, function () {
    return DB::table('users')->get();
  });
  $value = Cache::pull('key', 'default');
  Cache::put('key', 'value', $seconds = 10);
  Cache::put('key', 'value', now()->addMinutes(10));
  Cache::forget('key');
  ```
- Rate Limiting
  ```php
  // app/Providers/AppServiceProvider.php
  use Illuminate\Cache\RateLimiting\Limit;
  use Illuminate\Support\Facades\RateLimiter;

  RateLimiter::for('api', function (Request $request) {
      return Limit::perMinute(3)->by($request->user()?->id ?: $request->ip());
  });

  // routes/api.php
  Route::middleware('throttle:api');

  $executed = RateLimiter::attempt(
      'send-message:'.$user->id,
      $perMinute = 5,
      function() {
          // Send message...
      },
      $decayRate = 120,
  );

  if (! $executed) {
      return 'Too many messages sent!';
  }
  ```
- Task Scheduling
  ```
  php artisan schedule:list
  php artisan schedule:run
  php artisan schedule:work
  ```
  ```php
  Schedule::call(function () {
      \Log::info('Schedule closure');
  })->name('schedule-closure')->daily();

  Schedule::call(new InvocableClass())->daily();

  Schedule::command(SendEmails::class, ['2'])
      ->withoutOverlapping()
      ->runInBackground()
      ->emailOutputOnFailure('admin@site.com');

  Schedule::job(new BookJob(Book::first()))->everyFiveMinutes();
  ```
