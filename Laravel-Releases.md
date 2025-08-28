### [Laravel 12 (February 24th, 2025) - PHP 8.2 - 8.4](https://laravel.com/docs//releases)

---

### [Laravel 11 (March 12th, 2024) - PHP 8.2 - 8.4](https://laravel.com/docs//releases)

---

### [Laravel 10 (February 14th, 2023) - PHP 8.1 - 8.3](https://laravel.com/docs//releases)

---

### [Laravel 9 (February 8th, 2022) / PHP 8.0 - 8.1](https://laravel.com/docs//releases)

---

### [Laravel 8 (September 8th, 2020) / PHP 7.3 - 8.1](https://laravel.com/docs/8.x/releases)

- Laravel installer // _laravel new foo --jet -stack=livewire --teams_
- [Laravel Jetstream](https://jetstream.laravel.com/)
- [Laravel Sail](https://laravel.com/docs/8.x/sail)
- Models Directory // _app/Models_
- Model Factory Classes
  - extends Illuminate\Database\Eloquent\Factories\Factory
  - Model::factory()->count(50)->create()
  - return $this->state([])
  - Model::factory()->count(50)->create()
  - Model::factory()->has(Post::factory()->count(5))->count(50)->create()
  - Model::factory()->hasPosts(5)->count(50)->create()
  - Model::factory()->for(User::factory())->count(50)->create()
  - Model::factory()->forUser()->count(50)->create()
- Migration Squashing
  - php artisan schema:dump --prune
- Job Batching // _Illuminate\Support\Facades\Bus::batch([])_
- Improved Rate Limiting
  - App\Providers\RouteServiceProvider
  - throttle:api // _middleware_ It should be the same name in RateLimiter::for
  - Illuminate\Support\Facades\RateLimiter
  - RateLimiter::for('api')
  - Illuminate\Cache\RateLimiting\Limit
  - Limit::perMinute
- Improved Maintenance Mode
  - php artisan down --secret="1630542a-246b-4b66-afa1-dd72a4c43515"
  - php artisan down --render="errors::503"
- Closure Dispatch / Chain catch
- Dynamic Blade Components
  - \<x-dynamic-component :component="$componentName" class="mt-4" />
- Event Listener Improvements
  - Event::listen(function (Class $event){ })
  - Illuminate\Events\queueable
  - Event::listen(queueable(...))
- Time Testing Helpers
  - Illuminate\Support\Carbon::now()
  - $this->travel(5)->hours()
- Artisan serve Improvements // _automatic reloading when .env changes_
- Tailwind Pagination Views
- Routing Namespace Updates
  - App\Providers\RouteServiceProvider $namespace is null, before 'App\Http\Controllers'
  - Route::get('/users', [UserController::class, 'index']);
  - action([UserController::class, 'index']);
  - return Redirect::action([UserController::class, 'index']);

---

### [Laravel 7 (March 3rd, 2020) / PHP 7.2 - 8.0](https://laravel.com/docs/7.x/releases)

- [Laravel Sanctum](https://laravel.com/docs/7.x/sanctum) // _authentication system for SPAs_
- Custom Eloquent Casts
  - implements Illuminate\Contracts\Database\Eloquent\CastsAttributes - get, set
  - $casts // _Model property_
- Blade Component Tags & Improvements
  - php artisan make:component Notification
  - app/View/Components/Notification.php -> extends Illuminate\View\Component
  - resources/views/components/notification.blade.php
  - \<x-notification>\</x-notification>
  - \<x-slot name="sidebar">Sidebar\</x-slot>
- HTTP Client
  - Illuminate\Support\Facades\Http
  - Http::get('url')->json()
  - Http::fake()
- Fluent String Operations
  - Illuminate\Support\Str::of
  - Illuminate\Support\Stringable
- Route Model Binding Improvements
  - Key Customization // _Route::get('api/posts/{post:slug}', function (App\Post $post) {})_
  - Automatic Scoping // _Route::get('api/users/{user}/posts/{post:id}', function (User $user, Post $post) {})_
  - getRouteKeyName // _Model method_
- Multiple Mail Drivers
- Route Caching Speed Improvements // _php artisan route:cache_
- CORS Support
  - Cross-Origin Resource Sharing (CORS) OPTIONS request
  - cors configuration file
- Query Time Casts
  - withCasts // _Model object method_
- MySQL 8+ Database Queue Improvements
  - FOR UPDATE SKIP LOCKED
- Artisan test Command
  - php artisan test --group=feature
- Markdown Mail Template Improvements
- Stub Customization
  - php artisan stub:publish
- Queue maxExceptions Configuration

---

### [Laravel 6 (September 3rd, 2019) / PHP 7.2 - 8.0](https://laravel.com/docs/6.x/releases)

- Improved Exceptions Via [Ignition](https://github.com/facade/ignition)
- Improved Authorization Responses
  - $this->deny('Message') // _In Policy method_
  - $response = Gate::inspect('view', $model);
  - $response->allowed()
  - $response->denied()
- Job Middleware
  - public function middleware() // _In Job class_
- Lazy Collections
  - Illuminate\Support\LazyCollection::make()
  - Model::cursor()
- Eloquent Subquery Enhancements
  - Model::addSelect(['column' => Model::select()])
  - Model::orderByDesc(Model::select())
- [Laravel UI](https://github.com/laravel/ui)
  - composer require laravel/ui
  - php artisan ui vue --auth
- Password Confirmation
  - password.confirm // _middleware_
  - auth.password\*timeout // _configuration option_
