## [Inertia](https://inertiajs.com/)

- **Server-side setup**

  ```
  composer require inertiajs/inertia-laravel
  ```

  - resources/views/app.blade.php

  ```php
  @viteReactRefresh
  @vite(['resources/js/app.tsx', "resources/js/pages/{$page['component']}.tsx"])
  @inertiaHead
  @inertia
  ```

  - php artisan inertia:middleware

  ```php
  $middleware->web(append: [
      App\Http\Middleware\HandleInertiaRequests::class,
  ]);

  public function share(Request $request): array
  {
    return [
      ...parent::share($request),
      'name' => config('app.name'),
      'auth' => [
        'user' => $request->user(),
      ],
    ];
  }
  ```

  - app/Http/Controllers/EventController.php

  ```php
  return Inertia\Inertia::render('Event/Show', [
    'event' => $event->only('id','title'),
  ]);
  ```

- **Client-side setup**

  ```
  npm install @inertiajs/react
  ```

  - resources/js/app.tsx

  ```tsx
  import '../css/app.css';

  import { createInertiaApp } from '@inertiajs/react';
  import { resolvePageComponent } from 'laravel-vite-plugin/inertia-helpers';
  import { createRoot } from 'react-dom/client';

  const appName = import.meta.env.VITE_APP_NAME || 'Laravel';

  createInertiaApp({
    title: (title) => (title ? `${title} - ${appName}` : appName),
    resolve: (name) =>
      resolvePageComponent(
        `./pages/${name}.tsx`,
        import.meta.glob('./pages/**/*.tsx')
      ),
    setup({ el, App, props }) {
      const root = createRoot(el);

      root.render(<App {...props} />);
    },
    progress: {
      color: '#4B5563',
    },
  });
  ```

- **The page object**

  ```
  Request
  GET: http://example.com/events/80
  Accept: text/html, application/xhtml+xml
  X-Requested-With: XMLHttpRequest
  X-Inertia: true
  X-Inertia-Version: 6b16b94d7c51cbe5b1fa42aac98241d5

  Response
  HTTP/1.1 200 OK
  Content-Type: application/json
  Vary: X-Inertia
  X-Inertia: true
  ```

  ```json
  {
    "component": "Event",
    "props": {
      "event": {
        "id": 80,
        "title": "Birthday party"
      }
    },
    "url": "/events/80",
    "version": "6b16b94d7c51cbe5b1fa42aac98241d5",
    "encryptHistory": true,
    "clearHistory": false
  }
  ```

  ```
  Request
  GET: http://example.com/events
  Accept: text/html, application/xhtml+xml
  X-Requested-With: XMLHttpRequest
  X-Inertia: true
  X-Inertia-Version: 6b16b94d7c51cbe5b1fa42aac98241d5
  X-Inertia-Partial-Data: events
  X-Inertia-Partial-Component: Events

  Response
  HTTP/1.1 200 OK
  Content-Type: application/json
  ```

  ```json
  {
    "component": "Events",
    "props": {
      "auth": {...},       // NOT included
      "categories": [...], // NOT included
      "events": [...]      // included
    },
    "url": "/events/80",
    "version": "6b16b94d7c51cbe5b1fa42aac98241d5"
  }
  ```

- ## **Pages**

  ```
  resolve: (name) => resolvePageComponent(`./pages/${name}.tsx`, import.meta.glob('./pages/**/*.tsx'))
  return Inertia::render('User/Show', ['user' => $user]);
  resources/js/Pages/User/Show.jsx
  ```

- **Persistent layouts**

  ```tsx
  import Layout from './Layout'

  const Home = ({ user }) => {
    return (
      <>
        <H1>Welcome</H1>
        <p>Hello {user.name}, welcome to your first Inertia app!</p>
      </>
    )
  }

  Home.layout = page => <Layout children={page} title="Welcome" />

  export default Home
  ```

- **Default layout**

  ```ts
  import Layout from './Layout'

  createInertiaApp({
    resolve: name => {
      const pages = import.meta.glob('./Pages/**/*.jsx', { eager: true })
      let page = pages[`./Pages/${name}.jsx`]

      page.default.layout = page.default.layout || (page => <Layout children={page} />)

      return page
    },
    // ...
  })

  createInertiaApp({
    resolve: name => {
      const pages = import.meta.glob('./Pages/**/*.jsx', { eager: true })
      let page = pages[`./Pages/${name}.jsx`]

      page.default.layout = name.startsWith('Public/') ? undefined : page => <Layout children={page} />

      return page
    },
    // ...
  })
  ```

- ## **Responses**

  ```php
  Inertia::render('Dashboard', [
    // Primitive values
    'title' => 'Dashboard',
    'count' => 42,
    'active' => true,

    // Arrays and objects
    'settings' => ['theme' => 'dark', 'notifications' => true],

    // Arrayable objects (Collections, Models, etc.)
    'user' => auth()->user(), // Eloquent model
    'users' => User::all(), // Eloquent collection

    // API Resources
    'profile' => new UserResource(auth()->user()),

    // Responsable objects
    'data' => new JsonResponse(['key' => 'value']),

    // Closures
    'timestamp' => fn() => now()->timestamp,
  ]);
  ```

  - ProvidesInertiaProperty interface

  ```php
  use Inertia\PropertyContext;
  use Inertia\ProvidesInertiaProperty;

  class UserAvatar implements ProvidesInertiaProperty
  {
      public function __construct(protected User $user, protected int $size = 64) {}

      public function toInertiaProperty(PropertyContext $context): mixed
      {
          return $this->user->avatar
              ? Storage::url($this->user->avatar)
              : "https://ui-avatars.com/api/?name={$this->user->name}&size={$this->size}";
      }
  }

  Inertia::render('Profile', [
    'user' => $user,
    'avatar' => new UserAvatar($user, 128),
  ]);

  use Inertia\Inertia;
  use Inertia\PropertyContext;
  use Inertia\ProvidesInertiaProperty;

  class MergeWithShared implements ProvidesInertiaProperty
  {
      public function __construct(protected array $items = []) {}

      public function toInertiaProperty(PropertyContext $context): mixed
      {
          // Access the property key to get shared data
          $shared = Inertia::getShared($context->key, []);

          // Merge with the new items
          return array_merge($shared, $this->items);
      }
  }

  // Usage
  Inertia::share('notifications', ['Welcome back!']);

  return Inertia::render('Dashboard', [
      'notifications' => new MergeWithShared(['New message received']),
      // Result: ['Welcome back!', 'New message received']
  ]);
  ```

  - ProvidesInertiaProperties interface

  ```php
  use App\Models\User;
  use Illuminate\Container\Attributes\CurrentUser;
  use Inertia\RenderContext;
  use Inertia\ProvidesInertiaProperties;

  class UserPermissions implements ProvidesInertiaProperties
  {
      public function __construct(#[CurrentUser] protected User $user) {}

      public function toInertiaProperties(RenderContext $context): array
      {
          return [
              'canEdit' => $this->user->can('edit'),
              'canDelete' => $this->user->can('delete'),
              'canPublish' => $this->user->can('publish'),
              'isAdmin' => $this->user->hasRole('admin'),
          ];
      }
  }

  public function index(UserPermissions $permissions)
  {
      return Inertia::render('UserProfile', $permissions);

      // or...

      return Inertia::render('UserProfile')->with($permissions);
  }

  public function index(UserPermissions $permissions)
  {
      return Inertia::render('UserProfile', [
          'user' => auth()->user(),
          $permissions,
      ]);

      // or using method chaining...

      return Inertia::render('UserProfile')
          ->with('user', auth()->user())
          ->with($permissions);
  }
  ```

  - Root template data

  ```php
  <meta name="twitter:title" content="{{ $page['props']['event']->title }}">

  return Inertia::render('Event', ['event' => $event])
    ->withViewData(['meta' => $event->meta]);

  <meta name="description" content="{{ $meta }}">
  ```

- ## **Redirects**

  - When making a non-GET Inertia request manually or via a <Link> element, Inertia will automatically follow the redirect and update the page accordingly
    - return to_route('users.index');
  - When redirecting after a PUT, PATCH, or DELETE request, you must use a 303 response code, otherwise the subsequent request will not be treated as a GET request. A 303 redirect is very similar to a 302 redirect; however, the follow-up request is explicitly changed to a GET request.
  - If you're using one official server-side adapters, all redirects will automatically be converted to 303 redirects.
  - External redirects: redirect to an external website, or even another non-Inertia endpoint
    - window.location
    - return Inertia::location($url); // will generate a 409 Conflict response and include the destination URL in the X-Inertia-Location header

- ## **Routing**

  - All of your application's routes are defined server-side, you don't need Vue Router or React Router
  - Route::inertia('/about', 'About');
  - Generating URLs
    - Generate URLs server-side and include them as props
      - 'create_url' => route('users.create')
    - Using [Ziggy](https://github.com/tighten/ziggy)
    ```jsx
    <Link :href="route('users.create')">Create User</Link>
    ```

- ## **Title & meta**

  ```tsx
  import { Head } from '@inertiajs/vue3'

  <Head>
    <title>Your page title</title>
    <meta name="description" content="Your page description">
  </Head>

  // shorthand
  <Head title="Your page title" />

  createInertiaApp({
    title: title => `${title} - My App`,
    // ...
  })

  // Layout.vue

  import { Head } from '@inertiajs/vue3'

  <Head>
    <title>My app</title>
    <meta head-key="description" name="description" content="This is the default description" />
    <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
  </Head>

  // About.vue

  import { Head } from '@inertiajs/vue3'

  <Head>
    <title>About - My app</title>
    // head-key property will make sure the tag is only rendered once
    <meta head-key="description" name="description" content="This is a page specific description" />
  </Head>

  // custom head component that extends Inertia's <Head> component
  // AppHead.js

  import { Head } from '@inertiajs/react'

  const Site = ({ title, children }) => {
    return (
      <Head>
        <title>{title ? `${title} - My App` : 'My App'}</title>
        {children}
      </Head>
    )
  }

  export default Site

  import AppHead from './AppHead'

  <AppHead title="About">
  ```

- ## **Links**

  ```tsx
  import { Link } from '@inertiajs/react'
  import { show } from 'App/Http/Controllers/UserController' // Wayfinder

  <Link href="/">Home</Link>
  <Link href="/logout" method="post" as="button">Logout</Link>
  <Link href={show(1)}>John Doe</Link>
  <Link href="/endpoint" method="post" data={{ foo: bar }}>Save</Link>
  <Link href="/endpoint" headers={{ foo: bar }}>Save</Link>
  <Link replace href="/">Home</Link>
  <Link href="/search" data={query} preserveState>Search</Link>
  <Link preserveScroll href="/">Home</Link>
  <Link href="/users?active=true" only={['users']}>Show active</Link>

  import { usePage } from '@inertiajs/react'

  const { url, component } = usePage()

  // URL exact match...
  <Link href="/users" className={url === '/users' ? 'active' : ''}>Users</Link>
  // Component exact match...
  <Link href="/users" className={component === 'Users/Index' ? 'active' : ''}>Users</Link>
  // URL starts with (/users, /users/create, /users/1, etc.)...
  <Link href="/users" className={url.startsWith('/users') ? 'active' : ''}>Users</Link>
  // Component starts with (Users/Index, Users/Create, Users/Show, etc.)...
  <Link href="/users" className={component.startsWith('Users') ? 'active' : ''}>Users</Link>
  ```

  - While a link is making an active request, a _data-loading_ attribute is added

- ## **Manual visits**

- ## **Forms**

- ## **File uploads**

- ## **Validation**

- ## **Data & Props**

- ## **Shared data**
  - Server-side
  ```php
  class HandleInertiaRequests extends Middleware
  {
      public function share(Request $request)
      {
          return array_merge(parent::share($request), [
              // Synchronously...
              'appName' => config('app.name'),

              // Lazily...
              'auth.user' => fn () => $request->user()
                  ? $request->user()->only('id', 'name', 'email')
                  : null,

              'flash' => [
                'message' => fn () => $request->session()->get('message')
              ],
          ]);
      }
  }

  // Alternative

  use Inertia\Inertia;

  // Synchronously...
  Inertia::share('appName', config('app.name'));

  // Lazily...
  Inertia::share('user', fn (Request $request) => $request->user()
      ? $request->user()->only('id', 'name', 'email')
      : null
  );
  ```

  - Client-side
  ```js
  import { usePage } from '@inertiajs/react'

  export default function Layout({ children }) {
    const { auth } = usePage().props
    const { flash } = usePage().props

    return (
      <main>
        <header>
          You are logged in as: {auth.user.name}
        </header>
        <article>
          {flash.message && (
            <div class="alert">{flash.message}</div>
          )}
          {children}
        </article>
      </main>
    )
  }
  ```

- ## **Partial reloads**

- ## **Deferred props**

- ## **Merging props**

- ## **Polling**

- ## **Prefetching**

- ## **Load when visible**

- ## **Remembering state**

- ## **Security**

- ## **Authentication**

- ## **Authorization**

- ## **CSRF protection**

- ## **History encryption**

- ## **Advanced**

- ## **Asset versioning**

- ## **Code splitting (lazy-loading)**
  - Vite: omit the { eager: true } option, or set it to false
  ```tsx
  createInertiaApp({
    resolve: name => {
      const pages = import.meta.glob('./Pages/**/*.jsx', { eager: false })
      let page = pages[`./Pages/${name}.jsx`]

      page.default.layout = page.default.layout || (page => <Layout children={page} />)

      return page
    },
    // ...
  })
  ```
  - Webpack
    - enable dynamic imports via a Babel plugin
    - npm install @babel/plugin-syntax-dynamic-import
    - Next, create a .babelrc
    ```json
    {
      "plugins": ["@babel/plugin-syntax-dynamic-import"]
    }
    ```
    - resolve callback in your app's initialization code to use import instead of require
    - resolve: name => import(`./Pages/${name}`),
    - add the following configuration to your webpack configuration file
    ```json
    output: {
      chunkFilename: 'js/[name].js?id=[chunkhash]',
    }
    ```


- ## **Error handling**

- ## **Events**

- ## **Progress indicators**

  - [NProgress](https://ricostacruz.com/nprogress/)

  ```tsx
  createInertiaApp({
    progress: {
      // The delay after which the progress bar will appear, in milliseconds...
      delay: 250,

      // The color of the progress bar...
      color: '#29d',

      // Whether to include the default NProgress styles...
      includeCSS: true,

      // Whether the NProgress spinner will be shown...
      showSpinner: false,
    },
  });

  createInertiaApp({
    progress: false, // disable
  });

  // npm install nprogress
  // <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/nprogress/0.2.0/nprogress.min.css" />
  import NProgress from 'nprogress';
  import { router } from '@inertiajs/react';

  let timeout = null;

  router.on('start', () => {
    timeout = setTimeout(() => NProgress.start(), 250);
  });

  router.on('progress', (event) => {
    if (NProgress.isStarted() && event.detail.progress.percentage) {
      NProgress.set((event.detail.progress.percentage / 100) * 0.9);
    }
  });

  router.on('finish', (event) => {
    clearTimeout(timeout);
    if (!NProgress.isStarted()) {
      return;
    } else if (event.detail.visit.completed) {
      NProgress.done();
    } else if (event.detail.visit.interrupted) {
      NProgress.set(0);
    } else if (event.detail.visit.cancelled) {
      NProgress.done();
      NProgress.remove();
    }
  });
  ```

- ## **Scroll management**

- ## **Server-side rendering**

- ## **Testing**
