### [Laravel 12 (February 24th, 2025) - PHP 8.2 - 8.4](https://laravel.com/docs//releases)

- [New Application Starter Kits](https://laravel.com/docs/12.x/starter-kits)

---

### [Laravel 11 (March 12th, 2024) - PHP 8.2 - 8.4](https://laravel.com/docs//releases)

- [Named Arguments](https://www.php.net/manual/en/functions.arguments.php#functions.named-arguments)
- Streamlined Application Structure
  - bootstrap/app.php
    - withProviders(array $providers = [], bool $withBootstrapProviders = true) // _Register all the providers from bootstrap\providers.php_
    - withEvents(iterable|bool $discover = true) // _Autodiscovery event listeners from app\Listeners_
    - withRouting($web, $api, $commands, $channels, $pages, $health, $apiPrefix) // _Add php route files_
    - withMiddleware(function (Middleware $middleware) { ... }) // _\$middleware\->web()_
    - withCommands(array $commands = []) // _Autoregister all the commands from app\Console\Commands_
    - withExceptions(function (Exceptions $exceptions) { ... }) // _Exception Handling $exceptions\->dontFlash(), replace App\Exceptions\Handler_
  - Opt-in API and Broadcast Routing
    - php artisan install:api // _withRouting add api_
    - php artisan install:broadcasting // _withRouting add channels, resources\js add echo.js_
  - Built-in ServiceProvides have been moved into the framework itself
    - AuthServiceProvider, BroadcastServiceProvider, EventServiceProvider, RouteServiceProvider
  - Built-in Middlewares have been moved into the framework itself
    - Authenticate, EncryptCookies, PreventRequestsDuringMaintenance, RedirectIfAuthenticated, TrimStrings, TrustHosts, TrustProxies, VerifyCsrfToken
  - Config the built-in Middlewares in AppServiceProvider->boot()
    - Illuminate\Foundation\Http\Middleware\TrimStrings::except()
    - Illuminate\Auth\Middleware\RedirectIfAuthenticated::redirectUsing(fn ($request) => route('home'))
  - Laravel package -> ServiceProvider::addProviderToBootstrapFile
  - Scheduling (routes/console.php)
    - Illuminate\Support\Facades\Schedule::command('emails:send')->daily()
    - Illuminate\Support\Facades\Schedule::call(Command::class)->daily()
  - Base Controller Class // _Removed AuthorizesRequests, DispatchesJobs, ValidatesRequests_
  - SQLite as default database
  - Fewer Config Files // _php artisan config:publish_
- [Laravel Reverb](https://reverb.laravel.com/)
  - php artisan reverb:start
- Per-Second Rate Limiting // _Limit::perSecond(1)_
- Health Routing // _/up_
- Graceful Encryption Key Rotation // _APP_PREVIOUS_KEYS_
- Automatic Password Rehashing
  - config/hashing.php
  - BCRYPT_ROUNDS
- [Prompt Validation](https://laravel.com/docs/11.x/prompts)
- Queue Interaction Testing // _withFakeQueueInteractions_
- New Artisan Commands // _make:class, make:enum, make:interface, make:trait_
- Model Casts Improvements
  - Illuminate\Database\Eloquent\Casts\AsEnumCollection::of(ClassName::class)
  - Illuminate\Database\Eloquent\Casts\AsCollection::using(ClassName::class)
  - protected function casts() // _ Model_
- The once Function Memoization
- Inspecting Databases and Improved Schema Operations // _Schema::getTables()_
- Trait Illuminate\Support\Traits\Dumpable // _dump, dd_
- Limitless Limits for Eager Loading
  - User::with(['posts' => fn ($query) => $query->latest()->limit(5)])
- Retrying Asynchronous Requests // _Http::retry(5)_

---

### [Laravel 10 (February 14th, 2023) - PHP 8.1 - 8.3](https://laravel.com/docs//releases)

- Types
- Generate Secure Passwords //Illuminate\Support\Str::password()
- [Laravel Pennant](https://laravel.com/docs/10.x/pennant)
  - Laravel\Pennant\Feature::define()
  - php artisan pennant:feature NewApi
  - Laravel\Pennant\Feature::active()
- Process Interaction
  - $result = Illuminate\Support\Facades\Process::run('ls -la');
  - return $result->output();
- Test Profiling // _php artisan test --profile_
- Pest Scaffolding // _laravel new application --pest_
- Quicker Project Scaffolding // // _laravel new application --breeze_
- Generator CLI Prompts
- Horizon / Telescope Facelift
- registerPolicies method of the AuthServiceProvider is now invoked automatically

---

### [Laravel 9 (February 8th, 2022) / PHP 8.0 - 8.2](https://laravel.com/docs//releases)

- Anonymous Migration Classes
- Improved Eloquent Accessors / Mutators
  - Illuminate\Database\Eloquent\Casts\Attribute
  - return new Attribute(
  - get: fn ($value) => strtoupper($value),
  - set: fn ($value) => $value,
  - );
- Enum Eloquent Attribute Casting
  - $table->enum('difficulty', ['easy', 'hard']);
  - $table->enum('difficulty', Enum::class);
- Implicit Route Bindings With Enums
- Forced Scoping Of Route Bindings
  - scopeBindings
- Controller Route Groups
  - Route::controller(Controller::class)->group(function () {
  - ...
  - });
- Full Text Indexes / Where Clauses
  - $table->text('bio')->fullText();
  - DB::table('users')->whereFullText('bio', 'web developer')->get();
  - Laravel\Scout\Attributes\SearchUsingFullText;
  - Laravel\Scout\Attributes\SearchUsingPrefix;
  - #[SearchUsingPrefix(['id', 'email'])]
  - #[SearchUsingFullText(['bio'])]
- [Laravel Scout Database Engine](https://laravel.com/docs/9.x/scout#database-engine)
  - toSearchableArray
- Rendering Inline Blade Templates
- Slot Name Shortcut // _\<x-slot:title>_
- Checked / Selected Blade Directives
  - @checked(old('active', $user->active))
  - @selected(old('version') == $version)
- Bootstrap 5 Pagination Views
  - Paginator::useBootstrapFive();
- Improved Validation Of Nested Array Data
  - Rule::forEach
- [Laravel Breeze API](https://laravel.com/docs/9.x/starter-kits#breeze-and-next) & [Next.js](https://github.com/laravel/breeze-next)
- Improved Ignition Exception Page
- Improved route:list CLI Output
- Test Coverage Using Artisan test Command // _php artisan test --coverage requires Xdebug_
- Soketi Echo Server
- Improved Collections IDE Support
- New Helpers // _str and to_route_

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
  - [Laravel Mix](https://github.com/laravel-mix/laravel-mix)

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
- Illuminate\Support\Facades\Blade::withoutComponentTags() // _AppServiceProvider::boot_

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
- laravel/helpers
