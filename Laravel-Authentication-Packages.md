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

- Minimalist, lightweight authentication scaffolding, Blade templates/Livewire/Inertia
- composer require laravel/breeze --dev
- php artisan breeze:install
- npm install
- npm run dev
- php artisan migrate

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
