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

- **$ Variables**

  When working with frontend frameworks like Vue.js, you might encounter **variables preceded by a dollar sign ($)**. This convention typically indicates a global or shared variable that is made available to your client-side components.

  - Shared Data: Inertia.js allows you to share data from your backend to your frontend components. This is often done through the share() method in your HandleInertiaRequests middleware. This shared data becomes globally accessible on the frontend.
  - Accessing Shared Data: In your Vue.js components, you can access this shared data through the usePage() hook.
  - The Dollar Sign Convention: While not strictly enforced by Inertia itself, it's a common practice in Vue.js and other frameworks to prefix global or injected properties with a dollar sign to distinguish them from local component data, for example $page.

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

- ### **Pages**

  ```
  resolve: (name) => resolvePageComponent(`./pages/${name}.tsx`, import.meta.glob('./pages/**/*.tsx'))
  return Inertia::render('User/Show', ['user' => $user]);
  resources/js/Pages/User/Show.jsx
  ```

  ```tsx
  <script setup>
  import Layout from './Layout'
  import { Head } from '@inertiajs/vue3'

  defineProps({ user: Object })
  </script>

  <template>
      <Layout>
          <Head title="Welcome" />
          <h1>Welcome</h1>
          <p>Hello {{ user.name }}, welcome to your first Inertia app!</p>
      </Layout>
  </template>
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

  ```tsx
  <script>
  import Layout from './Layout'

  export default {
      // Using a render function...
      layout: (h, page) => h(Layout, [page]),

      // Using shorthand syntax...
      layout: Layout,
  }
  </script>

  <script setup>
      defineProps({ user: Object })
  </script>

  <template>
      <h1>Welcome</h1>
      <p>Hello {{ user.name }}, welcome to your first Inertia app!</p>
  </template>
  ```

  If you’re using **Vue 3.3+**, you can alternatively use **defineOptions** to define a layout within script setup. Older versions of Vue can use the [defineOptions plugin](https://vue-macros.dev/macros/define-options.html).

  ```tsx
  <script setup>
    import Layout from './Layout'
    defineOptions({ layout: Layout })
  </script>
  ```

  When using defineOptions({ layout: Layout }) with Vue 3's script setup, you **cannot directly pass props** to the Layout component within defineOptions. The layout option expects a **component reference** or an array of component references, not a component with props.

  To pass data to your Layout component when using this persistent layout approach, you have two primary methods: shared data ($page.props) or use a global event bus.

  The event bus allows your page component to emit an event with data, which your layout component can then listen for.

  ```tsx
  // ---------- Page
  <template>
    <div>
      <!-- ... page content ... -->
    </div>
  </template>

  <script setup>
  import { onMounted } from 'vue';
  import mitt from 'mitt'; // Or any other event bus library

  const emitter = mitt(); // Initialize your event bus

  defineOptions({ layout: AppLayout });

  onMounted(() => {
    emitter.emit('update-layout-title', 'My Page Title');
  });
  </script>

  // ---------- Layout
  <template>
    <div>
      <h1>{{ layoutTitle }}</h1>
      <slot />
    </div>
  </template>

  <script setup>
  import { ref, onMounted, onUnmounted } from 'vue';
  import mitt from 'mitt';

  const emitter = mitt();
  const layoutTitle = ref('Default Title');

  onMounted(() => {
    emitter.on('update-layout-title', (title) => {
      layoutTitle.value = title;
    });
  });

  onUnmounted(() => {
    emitter.off('update-layout-title');
  });
  </script>
  ```

- **Default layout**

  ```ts
  import Layout from './Layout'

  createInertiaApp({
    resolve: name => {
      const pages = import.meta.glob('./Pages/**/*.jsx', { eager: true })
      let page = pages[`./Pages/${name}.jsx`]

      page.default.layout = page.default.layout || (page => <Layout children={page} />)

      // Vue
      // page.default.layout = page.default.layout || Layout
      // page.default.layout ??= Layout

      return page
    },
    // ...
  })

  createInertiaApp({
    resolve: name => {
      const pages = import.meta.glob('./Pages/**/*.jsx', { eager: true })
      let page = pages[`./Pages/${name}.jsx`]

      page.default.layout = name.startsWith('Public/') ? undefined : page => <Layout children={page} />

      // Vue
      // page.default.layout = name.startsWith('Public/') ? undefined : Layout

      return page
    },
    // ...
  })
  ```

- ### **Responses**

  - To ensure that pages load quickly, only return the minimum data required for the page. Also, be aware that all data returned from the controllers will be visible client-side, so be sure to omit sensitive information.

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

- ### **Redirects**

  - When making a non-GET Inertia request manually or via a <Link> element, Inertia will automatically follow the redirect and update the page accordingly
    - return to_route('users.index');
  - When redirecting after a PUT, PATCH, or DELETE request, you must use a 303 response code, otherwise the subsequent request will not be treated as a GET request. A 303 redirect is very similar to a 302 redirect; however, the follow-up request is explicitly changed to a GET request.
  - If you're using one official server-side adapters, all redirects will automatically be converted to 303 redirects.
  - External redirects: redirect to an external website, or even another non-Inertia endpoint
    - window.location
    - return Inertia::location($url); // will generate a 409 Conflict response and include the destination URL in the X-Inertia-Location header

- ### **Routing**

  - All of your application's routes are defined server-side, you don't need Vue Router or React Router
  - Route::inertia('/about', 'About');
  - Generating URLs
    - Generate URLs server-side and include them as props
      - 'create_url' => route('users.create')
    - Using [Ziggy](https://github.com/tighten/ziggy)
    ```jsx
    <Link :href="route('users.create')">Create User</Link>
    ```

- ### **Title & meta**

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

- ### **Links**

  The wayfinder:generate command can be used to generate TypeScript definitions for your routes and controller methods. You don't require to run this command because when you run your Vite development server (e.g., npm run dev), the generate command will be automatically executed and re-executed as needed, ensuring your frontend's TypeScript definitions are always synchronized with your Laravel backend.

  ```
  php artisan wayfinder:generate
  ```

  By default, Wayfinder generates files in three directories (wayfinder, actions, and routes) within resources/js. You can safely .gitignore the wayfinder, actions, and routes directories as they are completely re-generated on every build.

  ```tsx
  import { Link } from '@inertiajs/react'
  import { show } from '@/actions/App/Http/Controllers/UserController' // Wayfinder

  <Link href="/">Home</Link>
  <Link href="/logout" method="post" as="button">Logout</Link>
  <Link href={show(1)}>John Doe</Link>
  <Link href="/endpoint" method="post" data={{ foo: bar }}>Save</Link>
  <Link href="/endpoint" headers={{ foo: bar }}>Save</Link>
  <Link replace href="/">Home</Link>
  <Link href="/search" data={query} preserveState>Search</Link>
  <Link preserveScroll href="/">Home</Link>
  <Link href="/users?active=true" only={['users']}>Show active</Link>
  <Link href="/another-page" viewTransition>Navigate</Link>

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

  ```tsx
  import { Link } from '@inertiajs/vue3'

  <Link href="/endpoint" method="post" :data="{ foo: bar }">Save</Link>
  <Link href="/endpoint" :headers="{ foo: bar }">Save</Link>
  <Link href="/" preserve-scroll>Home</Link>
  <input v-model="query" type="text" />
  <Link href="/search" :data="{ query }" preserve-state>Search</Link>
  <Link href="/users?active=true" :only="['users']">Show active</Link>
  <Link href="/another-page" view-transition>Navigate</Link>

  // URL exact match...
  <Link href="/users" :class="{ 'active': $page.url === '/users' }">Users</Link>
  // Component exact match...
  <Link href="/users" :class="{ 'active': $page.component === 'Users/Index' }">Users</Link>
  // URL starts with (/users, /users/create, /users/1, etc.)...
  <Link href="/users" :class="{ 'active': $page.url.startsWith('/users') }">Users</Link>
  // Component starts with (Users/Index, Users/Create, Users/Show, etc.)...
  <Link href="/users" :class="{ 'active': $page.component.startsWith('Users') }">Users</Link>
  ```

- ### **Manual visits**

  It’s also possible to manually make Inertia visits / requests programmatically via JavaScript. This is accomplished via the router.visit() method.

  ```jsx
  import { router } from '@inertiajs/vue3'

  router.visit(url, {
      method: 'get',
      data: {},
      replace: false,
      preserveState: false,
      preserveScroll: false,
      only: [],
      except: [],
      headers: {},
      errorBag: null,
      forceFormData: false,
      queryStringArrayFormat: 'brackets',
      async: false,
      showProgress: true,
      fresh: false,
      reset: [],
      preserveUrl: false,
      prefetch: false,
      viewTransition: false,
      onCancelToken: cancelToken => {},
      onCancel: () => {},
      onBefore: visit => {},
      onStart: visit => {},
      onProgress: progress => {},
      onSuccess: page => {},
      onError: errors => {},
      onFinish: visit => {},
      onPrefetching: () => {},
      onPrefetched: () => {},
  })

  router.get(url, data, options)
  router.post(url, data, options)
  router.put(url, data, options)
  router.patch(url, data, options)
  router.delete(url, options)
  router.reload(options) // Uses the current URL with preserveState and preserveScroll both set to true
  ```

  Uploading files via put or patch is not supported in Laravel. Instead, make the request via **post**, including a **_method** field set to put or patch.

  - Wayfinder

  ```jsx
  import { router } from '@inertiajs/vue3'
  import { show, store, destroy } from 'App/Http/Controllers/UserController'

  router.visit(show(1))
  router.post(store())
  router.delete(destroy(1))
  ```

  - Data

  ```js
  router.visit('/users', {
      method: 'post',
      data: {
          name: 'John Doe',
          email: 'john.doe@example.com',
      },
  })

  // get(), post(), put(), and patch() methods all accept data as their second argument
  router.post('/users', {
      name: 'John Doe',
      email: 'john.doe@example.com',
  })
  ```

  - Custom Headers

  ```js
  router.post('/users', data, {
      headers: {
          'Custom-Header': 'value',
      },
  })
  ```

  - Global Visit Options

  ```js
  import { createApp, h } from 'vue'
  import { createInertiaApp } from '@inertiajs/vue3'

  createInertiaApp({
      // ...
      defaults: {
          visitOptions: (href, options) => {
              return {
                  headers: {
                      ...options.headers,
                      'X-Custom-Header': 'value',
                  },
              }
          },
      },
  })
  ```

  - File Uploads

  ```js
  router.post('/companies', data, {
      forceFormData: true,
  })
  ```

  - Browser History

  ```js
  router.get('/users', { search: 'John' }, { replace: true })
  ```

  - Client Side Visits

  ```js
  // Update the browser’s history without making a server request.
  router.push({
      url: '/users',
      component: 'Users',
      props: { search: 'John' },
      clearHistory: false,
      encryptHistory: false,
      preserveScroll: false,
      preserveState: false,
      errorBag: null,
      onSuccess: (page) => {},
      onError: (errors) => {},
      onFinish: (visit) => {},
  })

  // All of the parameters are optional.
  // By default, all passed paramaters (except errorBag) will be merged with the current page.
  router.push({ url: '/users', component: 'Users' })

  // If you need access to the current page’s props, you can pass a function to the props option
  router.replace({
      props: (currentProps) => ({ ...currentProps, search: 'John' })
  })
  ```

  - Prop Helpers

  ```js
  // Updating page props without making server requests
  // Replace a prop value...
  router.replaceProp('user.name', 'Jane Smith')

  // Append to an array prop...
  router.appendToProp('messages', { id: 4, text: 'New message' })

  // Prepend to an array prop...
  router.prependToProp('tags', 'urgent')

  router.prependToProp('notifications', (currentValue, props) => {
    return {
        id: Date.now(),
        message: `Hello ${props.user.name}
    }
  )
  ```

  - State Preservation

  ```js
  // page visits to the same page create a fresh page component instance.
  // This causes any local state, such as form inputs, scroll positions, and focus states to be lost.
  router.get('/users', { search: 'John' }, { preserveState: true })

  router.get('/users', { search: 'John' }, { preserveState: 'errors' })

  // only preserve state if the response includes validation errors
  router.get('/users', { search: 'John' }, { preserveState: 'errors' })

  router.post('/users', data, {
      preserveState: (page) => page.props.someProp === 'value',
  })
  ```

  - Scroll Preservation

  ```js
  router.visit(url, { preserveScroll: true })

  // only preserve the scroll position if the response includes validation errors
  router.visit(url, { preserveScroll: 'errors' })

  // lazily evaluate the preserveScroll option based on the response by providing a callback
  router.post('/users', data, {
    preserveScroll: (page) => page.props.someProp === 'value',
  })
  ```

  - Partial Reloads

  ```js
  // request a subset of the props (data) from the server on subsequent visits to the same page
  router.get('/users', { search: 'John' }, { only: ['users'] })
  ```

  - View Transitions

  ```js
  router.visit('/another-page', { viewTransition: true })
  ```

  - Visit Cancellation

  ```js
  router.post('/users', data, {
    onCancelToken: (cancelToken) => (this.cancelToken = cancelToken),
  })

  // Cancel the visit...
  this.cancelToken.cancel()
  ```

  - Event Callbacks

  ```js
  router.post('/users', data, {
    onBefore: (visit) => {}, // Returning false will cause the visit to be cancelled
    onStart: (visit) => {},
    onProgress: (progress) => {},
    onSuccess: (page) => {},
    onError: (errors) => {},
    onCancel: () => {},
    onFinish: visit => {},
    onPrefetching: () => {},
    onPrefetched: () => {},
  })

  router.post(url, {
    onSuccess: () => {
        return Promise.all([
            this.firstTask(),
            this.secondTask()
        ])
    }
    onFinish: visit => {
        // Not called until firstTask() and secondTask() have finished
    },
  })
  ```

- ### **Forms**

- ### **File uploads**

- ### **Validation**

- ### **View Transitions**

- ## **Data & Props**

- ### **Shared data**
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

  ```tsx
  <script setup>
  import { computed } from 'vue'
  import { usePage } from '@inertiajs/vue3'

  const page = usePage()

  const user = computed(() => page.props.auth.user)
  </script>

  <template>
      <main>
          <header>
              You are logged in as: {{ user.name }}
          </header>
          <article>
              <slot />
          </article>
      </main>
  </template>
  ```

  Flash messages

  ```tsx
  <template>
      <main>
          <header></header>
          <article>
              <div v-if="$page.props.flash.message" class="alert">
                  {{ $page.props.flash.message }}
              </div>
              <slot />
          </article>
          <footer></footer>
      </main>
  </template>
  ```

- ### **Partial reloads**

- ### **Deferred props**

- ### **Merging props**

- ### **Polling**

- ### **Prefetching**

- ### **Load when visible**

- ### **Infinite Scroll**

- ### **Remembering state**

- ## **Security**

- ### **Authentication**

- ### **Authorization**

- ### **CSRF protection**

- ### **History encryption**

- ## **Advanced**

- ### **Asset versioning**

- ### **Code splitting (lazy-loading)**
  - Vite: omit the { eager: true } option, or set it to false
  ```tsx
  createInertiaApp({
    resolve: name => {
      const pages = import.meta.glob('./Pages/**/*.vue')

      return pages[`./Pages/${name}.vue`]()
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

- ### **Error handling**

- ### **Events**

- ### **Progress indicators**

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

  import { progress } from '@inertiajs/vue3'

  progress.start()      // Begin progress animation
  progress.set(0.25)    // Set to 25% complete
  progress.finish()     // Complete and fade out
  progress.reset()      // Reset to start
  progress.remove()     // Complete and remove from DOM
  progress.hide()       // Hide progress bar
  progress.reveal()     // Show progress bar

  progress.isStarted()  // Returns boolean
  progress.getStatus()  // Returns current percentage or null

  progress.hide()    // Counter = 1, bar hidden
  progress.hide()    // Counter = 2, bar still hidden
  progress.reveal()  // Counter = 1, bar still hidden
  progress.reveal()  // Counter = 0, bar now visible

  // Force reveal bypasses the counter
  progress.reveal(true)

  // Disable the progress indicator
  router.get('/settings', {}, { showProgress: false })
  router.get('/settings', {}, { async: true })
  // Enable the progress indicator with async requests
  router.get('/settings', {}, { async: true, showProgress: true })
  ```

- ### **Scroll management**

  ```jsx
  // When navigating between pages, automatically resetting the scroll position of the document body
  // (as well as any scroll regions you’ve defined) back to the top.
  // Prevent the default scroll resetting when making visits
  router.visit(url, { preserveScroll: true })

  // only preserve the scroll position if the response includes validation errors
  router.visit(url, { preserveScroll: 'errors' })

  // lazily evaluate the preserveScroll option based on the response by providing a callback
  router.post('/users', data, {
    preserveScroll: (page) => page.props.someProp === 'value',
  })

  <Link href="/" preserve-scroll>Home</Link>
  ```

  If your app doesn’t use document body scrolling, but instead has scrollable elements (using the overflow CSS property), scroll resetting will not work. In these situations, you must tell Inertia which scrollable elements to manage by adding the scroll-region attribute to the element.

  ```html
  <div class="overflow-y-auto" scroll-region="">
    <!-- Your page content -->
  </div>
  ```

- ### **Server-side rendering**

- ### **Testing**
