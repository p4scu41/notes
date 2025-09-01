References

- [Which Laravel authentication package to choose?](https://medium.com/@antoine.lame/which-laravel-authentication-package-to-choose-290551a82a44)
  ![Laravel-Authentication-Packages-How-To-Choose](Laravel-Authentication-Packages-How-To-Choose.webp)
- [Laravel Authentication Packages: A Comparative Analysis](https://aglowiditsolutions.com/blog/laravel-authentication/)
  ![Laravel-Authentication-Packages-Comparison](./Laravel-Authentication-Packages-Comparison.jpg)

---

### [Laravel UI](https://github.com/laravel/ui)

- legacy, use Bootstrap CSS framework
- Bootstrap, React, or Vue
- composer require laravel/ui
- php artisan ui vue --auth
- npm install
- npm run dev

---

### [Laravel Breeze](https://github.com/laravel/breeze)

- Starter Kits uses Breeze
- Minimalist, lightweight authentication scaffolding
- Includes login, registration, password reset, email verification, and password confirmation
- Includes a simple "profile" page where the user may update their name, email address, and password
- Blade templates styled with Tailwind CSS
- Provides scaffolding options based on Livewire or Inertia (Vue or React)
- _API only_ option scaffold an authentication API that is ready to authenticate modern JavaScript applications such as those powered by Next or Nuxt
- [Next reference implementation](https://github.com/laravel/breeze-next)
- Includes [Laravel Sanctum](https://github.com/laravel/sanctum) (but it is not used) and [Ziggy](https://github.com/tighten/ziggy)
- Login is based on Session
- Uses uppercase resources/js directories
- composer require laravel/breeze --dev
- php artisan breeze:install
  - Which Breeze stack would you like to install?
    - [ ] Blade with Alpine
    - [ ] Livewire (Volt Class API) with Alpine
    - [ ] Livewire (Volt Functional API) with Alpine
    - [x] React with Inertia
    - [ ] Vue with Inertia
    - [ ] API only
  - Would you like any optional features?
    - [x] Dark mode
    - [ ] Inertia SSR
    - [x] TypeScript
    - [x] ESLint with Prettier
  - Which testing framework do you prefer?
    - [x] Pest
    - [ ] PHPUnit
- php artisan migrate
- npm install --legacy-peer-deps
- npm run dev
- Files created/updated
  - app/Http/Controllers/Auth/
  - app/Http/Controllers/ProfileController.php
  - app/Http/Middleware/HandleInertiaRequests.php
  - app/Http/Requests/Auth/LoginRequest.php
  - app/Providers/AppServiceProvider.php // Vite::prefetch(concurrency: 3);
  - bootstrap/app.php
    - withMiddleware -> web
    - \App\Http\Middleware\HandleInertiaRequests::class
    - \Illuminate\Http\Middleware\AddLinkHeadersForPreloadedAssets::class
  - resources/css/app.css // @tailwind
  - resources/js/app.ts
  - resources/js/bootstrap.ts
  - resources/js/Components/ // General Vue Components
  - resources/js/Layouts/
  - resources/js/Pages/
  - resources/js/types/
  - resources/views/app.blade.php
    - @routes // Ziggy
    - @vite(['resources/js/app.ts', "resources/js/Pages/{$page['component']}.vue"])
    - @inertiaHead
    - @inertia
  - routes/auth.php
  - routes/web.php
  - tests/Feature/Auth/
  - tests/Feature/ProfileTest.php
  - tests/Pest.php
  - .eslintrc.cjs, .prettierrc, postcss.config.js, tailwind.config.js, tsconfig.json, vite.config.js

---

### [Laravel Starter Kits](https://laravel.com/starter-kits)

- Evolution of Laravel Breeze

---

### [Laravel Fortify](https://github.com/laravel/fortify)

- Headless authentication Backend-only, handles the core authentication logic (login, registration, password reset, etc.)
- composer require laravel/fortify
- php artisan fortify:install
- php artisan vendor:publish --tag=fortify-config
- php artisan migrate

---

### [Laravel Jetstream](https://jetstream.laravel.com)

- Feature-rich, Livewire/Inertia + Teams, API support via Fortify/Sanctum
- composer require laravel/jetstream
- php artisan jetstream:install inertia --teams --dark
- npm install --legacy-peer-deps
- npm run build
- php artisan migrate
- npm run dev
- php artisan vendor:publish --tag=jetstream-views

---

### [Laravel Sanctum](https://github.com/laravel/sanctum)

- API token authentication, issue personal access tokens for API access or manage authentication for SPAs and mobile applications.
- php artisan install:api // composer require laravel/sanctum
- php artisan vendor:publish --tag="sanctum-migrations"
- php artisan migrate

---

### [Laravel Passport](https://github.com/laravel/passport)

- OAuth2 server and API authentication package
- built on top of the League [OAuth2 server](https://github.com/thephpleague/oauth2-server)
- php artisan install:api --passport
- php artisan passport:keys
- php artisan vendor:publish --tag=passport-config

---

### [Laravel Socialite](https://github.com/laravel/socialite)

- OAuth authentication with Bitbucket, Facebook, GitHub, GitLab, Google, LinkedIn, Slack, Twitch, and X
- composer require laravel/socialite
