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

  - Configuring Defaults

  ```js
  createInertiaApp({
      // ...
      defaults: {
          form: {
              recentlySuccessfulDuration: 5000,
          },
          prefetch: {
              cacheFor: "1m",
              hoverDelay: 150,
          },
          visitOptions: (href, options) => {
              return {
                  headers: {
                      ...options.headers,
                      "X-Custom-Header": "value",
                  },
              };
          },
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
    - [Wayfinder](https://github.com/laravel/wayfinder)

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

  Inertia provides two primary ways to build forms: the `<Form>` component and the `useForm` helper. Both integrate with your server-side framework's validation and handle form submissions without full page reloads.

  #### Form Component

  Inertia provides a `<Form>` component that behaves much like a classic HTML form, but uses Inertia under the hood to avoid full page reloads. This is the simplest way to get started with forms in Inertia.

  ```jsx
  <script setup>
  import { Form } from '@inertiajs/vue3'
  </script>

  <template>
      <Form action="/users" method="post">
          <input type="text" name="name" />
          <input type="email" name="email" />
          <button type="submit">Create User</button>
      </Form>
  </template>
  ```

  Just like a traditional HTML form, there is no need to attach a `v-model` to your input fields, just give each input a `name` attribute and the `Form` component will handle the data submission for you.

  The component also supports nested data structures, file uploads, and dotted key notation.

  ```jsx
  <template>
      <Form action="/reports" method="post">
          <input type="text" name="name" />
          <textarea name="report[description]"></textarea>
          <input type="text" name="report[tags][]" />
          <input type="file" name="documents" multiple />
          <button type="submit">Create Report</button>
      </Form>
  </template>
  ```

  You can pass a `transform` prop to modify the form data before submission, although hidden inputs work too.

  ```jsx
  <template>
      <Form
          action="/posts"
          method="post"
          :transform="data => ({ ...data, user_id: 123 })"
      >
          <input type="text" name="title" />
          <button type="submit">Create Post</button>
      </Form>
  </template>
  ```

  - Wayfinder

  When using [Wayfinder](https://github.com/laravel/wayfinder), you can pass the resulting object directly to the `action` prop. The Form component will infer the HTTP method and URL from the Wayfinder object.

  ```jsx
  <script setup>
  import { Form } from '@inertiajs/vue3'
  import { store } from 'App/Http/Controllers/UserController'
  </script>

  <template>
      <Form :action="store()">
          <input type="text" name="name" />
          <input type="email" name="email" />
          <button type="submit">Create User</button>
      </Form>
  </template>
  ```

  - Default Values

  You can set default values for form inputs using standard HTML attributes. Use `defaultValue` for text inputs and textareas, and `defaultChecked` for checkboxes and radios.

  ```jsx
  <template>
      <Form action="/users" method="post">
          <input type="text" name="name" defaultValue="John Doe" />

          <select name="country">
              <option value="us">United States</option>
              <option value="ca">Canada</option>
              <option value="uk" selected>United Kingdom</option>
          </select>

          <input type="checkbox" name="subscribe" value="yes" defaultChecked />

          <button type="submit">Submit</button>
      </Form>
  </template>
  ```

  - Checkbox Inputs

  When working with checkboxes, you may want to add an explicit `value` attribute such as `value="1"`. Without a value attribute, checked checkboxes will submit as `"on"`, which some server-side validation rules may not recognize as a proper boolean value.

  - Slot Props

  The `<Form>` component exposes reactive state and helper methods through its default slot, giving you access to form processing state, errors, and utility functions.

  ```jsx
  <template>
      <Form
          action="/users"
          method="post"
          #default="{
              errors,
              hasErrors,
              processing,
              progress,
              wasSuccessful,
              recentlySuccessful,
              setError,
              clearErrors,
              resetAndClearErrors,
              defaults,
              isDirty,
              reset,
              submit,
          }"
      >
          <input type="text" name="name" />

          <div v-if="errors.name">
              {{ errors.name }}
          </div>

          <button type="submit" :disabled="processing">
              {{ processing ? 'Creating...' : 'Create User' }}
          </button>

          <div v-if="wasSuccessful">User created successfully!</div>
      </Form>
  </template>
  ```

  The `defaults` method allows you to update the form's default values to match the current field values. When called, subsequent `reset()` calls will restore fields to these new defaults, and the `isDirty` property will track changes from these updated defaults. Unlike `useForm`, this method accepts no arguments and always uses all current form values.

  The `errors` object uses dotted notation for nested fields, allowing you to display validation messages for complex form structures.

  ```jsx
  <Form action="/users" method="post" #default="{ errors }">
      <input type="text" name="user.name" />
      <div v-if="errors['user.name']">{{ errors['user.name'] }}</div>
  </Form>
  ```

  - Props and Options

  In addition to `action` and `method`, the `<Form>` component accepts several props. Many of them are identical to the options available in Inertia's visit options.

  ```jsx
  <template>
      <Form
          action="/profile"
          method="put"
          error-bag="profile"
          query-string-array-format="indices"
          :headers="{ 'X-Custom-Header': 'value' }"
          :show-progress="false"
          :transform="data => ({ ...data, timestamp: Date.now() })"
          :invalidate-cache-tags="['users', 'dashboard']"
          disable-while-processing
          :options="{
              preserveScroll: true,
              preserveState: true,
              preserveUrl: true,
              replace: true,
              only: ['users', 'flash'],
              except: ['secret'],
              reset: ['page'],
          }"
      >
          <input type="text" name="name" />
          <button type="submit">Update</button>
      </Form>
  </template>
  ```

  Some props are intentionally grouped under `options` instead of being top-level to avoid confusion. For example, `only`, `except`, and `reset` relate to *partial reloads*, not *partial submissions*. The general rule: top-level props are for the form submission itself, while `options` control how Inertia handles the subsequent visit.

  When setting the `disable-while-processing` prop, the `Form` component will add the `inert` attribute to the HTML `form`tag while the form is processing to prevent user interaction.

  To style the form while it's processing, you can target the inert form in the following ways.

  ```jsx
  <Form
      action="/profile"
      method="put"
      disableWhileProcessing
      className="inert:opacity-50 inert:pointer-events-none"
  >
      {/* Your form fields here */}
  </Form>
  ```

  - Events

  The `<Form>` component emits all the standard visit events for form submissions.

  ```jsx
  <template>
      <Form
          action="/users"
          method="post"
          @before="handleBefore"
          @start="handleStart"
          @progress="handleProgress"
          @success="handleSuccess"
          @error="handleError"
          @finish="handleFinish"
          @cancel="handleCancel"
          @cancelToken="handleCancelToken"
      >
          <input type="text" name="name" />
          <button type="submit">Create User</button>
      </Form>
  </template>
  ```

  - Resetting the Form

  The `Form` component provides several attributes that allow you to reset the form after a submission.

  `resetOnSuccess` may be used to reset the form after a successful submission.

  ```jsx
  <template>
      <!-- Reset the entire form on success -->
      <Form action="/users" method="post" resetOnSuccess>
          <input type="text" name="name" />
          <input type="email" name="email" />
          <button type="submit">Submit</button>
      </Form>

      <!-- Reset specific fields on success -->
      <Form action="/users" method="post" :resetOnSuccess="['name']">
          <input type="text" name="name" />
          <input type="email" name="email" />
          <button type="submit">Submit</button>
      </Form>
  </template>
  ```

  `resetOnError` may be used to reset the form after errors.

  ```jsx
  <template>
      <!-- Reset the entire form on success -->
      <Form action="/users" method="post" resetOnError>
          <input type="text" name="name" />
          <input type="email" name="email" />
          <button type="submit">Submit</button>
      </Form>

      <!-- Reset specific fields on success -->
      <Form action="/users" method="post" :resetOnError="['name']">
          <input type="text" name="name" />
          <input type="email" name="email" />
          <button type="submit">Submit</button>
      </Form>
  </template>
  ```

  - Setting New Default Values

  The `Form` component provides the `setDefaultsOnSuccess` attribute to set the current form values as the new defaults after a successful submission.

  ```jsx
  <template>
      <Form action="/users" method="post" setDefaultsOnSuccess>
          <input type="text" name="name" />
          <input type="email" name="email" />
          <button type="submit">Submit</button>
      </Form>
  </template>
  ```

  - Dotted Key Notation

  The `<Form>` component supports dotted key notation for creating nested objects from flat input names. This provides a convenient way to structure form data.

  ```jsx
  <template>
      <Form action="/users" method="post">
          <input type="text" name="user.name" />
          <input type="text" name="user.skills[]" />
          <input type="text" name="address.street" />
          <button type="submit">Submit</button>
      </Form>
  </template>
  ```

  The example above would generate the following data structure.

  ```json
  {
      "user": {
          "name": "John Doe",
          "skills": ["JavaScript"]
      },
      "address": {
          "street": "123 Main St"
      }
  }
  ```

  If you need literal dots in your field names (not as nested object separators), you can escape them using backslashes.

  ```jsx
  <template>
      <Form action="/config" method="post">
          <input type="text" name="app\.name" />
          <input type="text" name="settings.theme\.mode" />
          <button type="submit">Save</button>
      </Form>
  </template>
  ```

  The example above would generate the following data structure.

  ```json
  {
      "app.name": "My Application",
      "settings": {
          "theme.mode": "dark"
      }
  }
  ```

  - Programmatic Access

  You can access the form's methods programmatically using refs. This provides an alternative to `slot props` when you need to trigger form actions from outside the form.

  ```jsx
  <script setup>
  import { ref } from 'vue'
  import { Form } from '@inertiajs/vue3'

  const formRef = ref()

  const handleSubmit = () => {
      formRef.value.submit()
  }
  </script>

  <template>
      <Form ref="formRef" action="/users" method="post">
          <input type="text" name="name" />
          <button type="submit">Submit</button>
      </Form>

      <button @click="handleSubmit">Submit Programmatically</button>
  </template>
  ```

  #### Form Helper

  In addition to the `<Form>` component, Inertia also provides a `useForm` helper for when you need programmatic control over your form's data and submission behavior.

  ```jsx
  <script setup>
  import { useForm } from '@inertiajs/vue3'

  const form = useForm({
      email: null,
      password: null,
      remember: false,
  })
  </script>

  <template>
      <form @submit.prevent="form.post('/login')">
          <input type="text" v-model="form.email">
          <div v-if="form.errors.email">{{ form.errors.email }}</div>
          <input type="password" v-model="form.password">
          <div v-if="form.errors.password">{{ form.errors.password }}</div>
          <input type="checkbox" v-model="form.remember"> Remember Me
          <button type="submit" :disabled="form.processing">Login</button>
      </form>
  </template>
  ```

  To submit the form, you may use the `get`, `post`, `put`, `patch`and `delete` methods.

  ```js
  form.submit(method, url, options)
  form.get(url, options)
  form.post(url, options)
  form.put(url, options)
  form.patch(url, options)
  form.delete(url, options)
  ```

  The submit methods support all of the typical `visit options`, such as `preserveState`, `preserveScroll`, and event callbacks, which can be helpful for performing tasks on successful form submissions. For example, you might use the `onSuccess` callback to reset inputs to their original state.

  ```js
  form.post('/profile', {
      preserveScroll: true,
      onSuccess: () => form.reset('password'),
  })
  ```

  If you need to modify the form data before it's sent to the server, you can do so via the `transform()` method.

  ```js
  form
      .transform((data) => ({
          ...data,
          remember: data.remember ? 'on' : '',
      }))
      .post('/login')
  ```

  You can use the `processing` property to track if a form is currently being submitted. This can be helpful for preventing double form submissions by disabling the submit button.

  ```jsx
  <button type="submit" :disabled="form.processing">Submit</button>
  ```

  If your form is uploading files, the current progress event is available via the `progress` property, allowing you to easily display the upload progress.

  ```jsx
  <progress v-if="form.progress" :value="form.progress.percentage" max="100">
      {{ form.progress.percentage }}%
  </progress>
  ```

  - Form Errors

  If there are form validation errors, they are available via the `errors` property. When building Laravel powered Inertia applications, form errors will automatically be populated when your application throws instances of `ValidationException`, such as when using `{'$request->validate()'}`.

  ```jsx
  <div v-if="form.errors.email">{{ form.errors.email }}</div>
  ```

  To determine if a form has any errors, you may use the `hasErrors` property. To clear form errors, use the `clearErrors()` method.

  ```js
  // Clear all errors...
  form.clearErrors()

  // Clear errors for specific fields...
  form.clearErrors('field', 'anotherfield')
  ```

  If you're using client-side input validation libraries or do client-side validation manually, you can set your own errors on the form using the `setErrors()` method.

  ```js
  // Set a single error...
  form.setError('field', 'Your error message.');

  // Set multiple errors at once...
  form.setError({
      foo: 'Your error message for the foo field.',
      bar: 'Some other error for the bar field.'
  });
  ```

  Unlike an actual form submission, the page's props remain unchanged when manually setting errors on a form instance.

  When a form has been successfully submitted, the `wasSuccessful` property will be `true`. In addition to this, forms have a `recentlySuccessful` property, which will be set to `true` for two seconds after a successful form submission. This property can be utilized to show temporary success messages.

  You may customize the duration of the `recentlySuccessful` state by setting the `form.recentlySuccessfulDuration` option in your `application defaults`. The default value is `2000` milliseconds.

  - Resetting the Form

  To reset the form's values back to their default values, you can use the `reset()` method.

  ```js
  // Reset the form...
  form.reset()

  // Reset specific fields...
  form.reset('field', 'anotherfield')
  ```

  Sometimes, you may want to restore your form fields to their default values and clear any validation errors at the same time. Instead of calling `reset()` and `clearErrors()` separately, you can use the `resetAndClearErrors()` method, which combines both actions into a single call.

  ```js
  // Reset the form and clear all errors...
  form.resetAndClearErrors()

  // Reset specific fields and clear their errors...
  form.resetAndClearErrors('field', 'anotherfield')
  ```

  - Setting New Default Values

  If your form's default values become outdated, you can use the `defaults()` method to update them. Then, the form will be reset to the correct values the next time the `reset()` method is invoked.

  ```js
  // Set the form's current values as the new defaults...
  form.defaults()

  // Update the default value of a single field...
  form.defaults('email', 'updated-default@example.com')

  // Update the default value of multiple fields...
  form.defaults({
      name: 'Updated Example',
      email: 'updated-default@example.com',
  })
  ```

  - Form Field Change Tracking

  To determine if a form has any changes, you may use the `isDirty` property.

  ```jsx
  <div v-if="form.isDirty">There are unsaved form changes.</div>
  ```

  - Canceling Form Submissions

  To cancel a form submission, use the `cancel()` method.

  ```js
  form.cancel()
  ```

  - Form Data and History State

  To instruct Inertia to store a form's data and errors in `history state`, you can provide a unique form key as the first argument when instantiating your form.

  ```js
  import { useForm } from '@inertiajs/vue3'

  const form = useForm('CreateUser', data)
  const form = useForm(`EditUser:${user.id}\
  ```

  - Wayfinder

  You can pass the Wayfinder resulting object directly to the `form.submit` method. The form helper will infer the HTTP method and URL from the Wayfinder object.

  ```js
  import { useForm } from '@inertiajs/vue3'
  import { store } from 'App/Http/Controllers/UserController'

  const form = useForm({
      name: 'John Doe',
      email: 'john.doe@example.com',
  })

  form.submit(store())
  ```

  #### Server-Side Responses

  When using Inertia, you don't typically inspect form responses client-side like you would with traditional XHR/fetch requests. Instead, your server-side route or controller issues a `redirect` response after processing the form, often redirecting to a success page.

  ```php
  class UsersController extends Controller
  {
      public function index()
      {
          return Inertia::render('Users/Index', [
              'users' => User::all(),
          ]);
      }

      public function store(Request $request)
      {
          User::create($request->validate([
              'first_name' => ['required', 'max:50'],
              'last_name' => ['required', 'max:50'],
              'email' => ['required', 'max:50', 'email'],
          ]));

          return to_route('users.index');
      }
  }
  ```

  #### Server-Side Validation

  Both the `<Form>` component and `useForm` helper automatically handle server-side validation errors. When your server returns validation errors, they're automatically available in the `errors` object without any additional configuration.

  Unlike traditional XHR/fetch requests where you might check for a `422` status code, Inertia handles validation errors as part of its redirect-based flow, just like classic server-side form submissions, but without the full page reload.

  #### Manual Form Submissions

  It's also possible to submit forms manually using Inertia's `router` methods directly, without using the `<Form>` component or `useForm` helper:

  ```jsx
  <script setup>
  import { reactive } from 'vue'
  import { router } from '@inertiajs/vue3'

  const form = reactive({
      first_name: null,
      last_name: null,
      email: null,
  })

  function submit() {
      router.post('/users', form)
  }
  </script>

  <template>
      <form @submit.prevent="submit">
          <label for="first_name">First name:</label>
          <input id="first_name" v-model="form.first_name" />
          <label for="last_name">Last name:</label>
          <input id="last_name" v-model="form.last_name" />
          <label for="email">Email:</label>
          <input id="email" v-model="form.email" />
          <button type="submit">Submit</button>
      </form>
  </template>
  ```

  #### File Uploads

  When making requests or form submissions that include files, Inertia will automatically convert the request data into a `FormData` object. This works with the `<Form>` component, `useForm` helper, and manual router submissions.

- ### **File uploads**

  When making Inertia requests that include files (even nested files), Inertia will automatically convert the request data into a FormData object. This conversion is necessary in order to submit a multipart/form-data request via XHR.

  ```jsx
  <script setup>
  import { useForm } from '@inertiajs/vue3'

  const form = useForm({
      name: null,
      avatar: null,
  })

  function submit() {
      form.post('/users')
  }
  </script>

  <template>
      <form @submit.prevent="submit">
          <input type="text" v-model="form.name" />
          <input type="file" @input="form.avatar = $event.target.files[0]" />
          <progress v-if="form.progress" :value="form.progress.percentage" max="100">
              {{ form.progress.percentage }}%
          </progress>
          <button type="submit">Submit</button>
      </form>
  </template>
  ```

  Uploading files using a `multipart/form-data` request is not natively supported in some server-side frameworks when using the `PUT`, `PATCH`, or `DELETE` HTTP methods. The simplest workaround for this limitation is to simply upload files using a POST request and form method spoofing by including a `_method` attribute in the data of your request.

  ```jsx
  import { router } from '@inertiajs/vue3'

  router.post(`/users/${user.id}`, {
      _method: 'put',
      avatar: form.avatar,
  })
  ```

- ### **Validation**

  Handling server-side validation errors works differently because Inertia never receives `422` responses.

  On submitting, if there are server-side validation errors, you don't return those errors as a `422` JSON response. Instead, you redirect (server-side) the user back to the form page they were previously on, flashing the validation errors in the session. These validation errors automatically get shared with Inertia, making them available client-side as page props which you can display in your form. Inertia checks the `page.props.errors` object for the existence of any errors. In the event that errors are present, the request's `onError()` callback will be called instead of the `onSuccess()` callback.

  ```jsx
  import { reactive } from 'vue'
  import { router } from '@inertiajs/vue3'

  defineProps({ errors: Object }) // Important to get access in the template

  const form = reactive({
      first_name: null,
      last_name: null,
      email: null,
  })

  function submit() {
      router.post('/users', form)
  }
  </script>

  <template>
      <form @submit.prevent="submit">
          <label for="first_name">First name:</label>
          <input id="first_name" v-model="form.first_name" />
          <div v-if="errors.first_name">{{ errors.first_name }}</div>
          <label for="last_name">Last name:</label>
          <input id="last_name" v-model="form.last_name" />
          <div v-if="errors.last_name">{{ errors.last_name }}</div>
          <label for="email">Email:</label>
          <input id="email" v-model="form.email" />
          <div v-if="errors.email">{{ errors.email }}</div>
          <button type="submit">Submit</button>
      </form>
  </template>
  ```

  When using the Vue adapters, you may also access the errors via the `$page.props.errors` object.

  By default, Inertia's Laravel adapter returns only the first validation error for each field. You may opt-in to receiving all errors by setting the `$withAllErrors` property to `true` in your middleware.

  ```php
  class HandleInertiaRequests extends Middleware
  {
      protected $withAllErrors = true;

      // ...
  }
  ```

  When enabled, each field will contain an array of error strings instead of a single string.

  ```jsx
  <p v-for="error in errors.email">{{ error }}</p>
  ```

  You may configure TypeScript to expect arrays instead of strings in a `global.d.ts` file.

  ```ts
  declare module '@inertiajs/core' {
      export interface InertiaConfig {
          errorValueType: string[]
      }
  }
  ```

  While handling errors in Inertia is similar to full page form submissions, you don't even need to manually repopulate old form input data. Inertia automatically preserves the `component state` for `post`, `put`, `patch`, and `delete` requests. Therefore, all the old form input data remains exactly as it was when the user submitted the form.

  If you're using the `form helper`, it's not necessary to use error bags since validation errors are automatically scoped to the form object making the request.

  For pages that have more than one form, it's possible to encounter conflicts when displaying validation errors if two forms share the same field names. To solve this issue, you can use "error bags". `Error bags` scope the validation errors returned from the server within a unique key specific to that form. For example, you might have a `createCompany` error bag for the first form and a `createUser` error bag for the second form.

  ```js
  import { router } from '@inertiajs/vue3'

  router.post('/companies', data, {
      errorBag: 'createCompany',
  })

  router.post('/users', data, {
      errorBag: 'createUser',
  })
  ```

  Specifying an error bag will cause the validation errors to come back from the server within `page.props.errors.createCompany` and `page.props.errors.createUser`.

- ### **View Transitions**

  You may enable view transitions for a visit by setting the viewTransition option to true. By default, this will apply a cross-fade transition between pages.

  ```jsx
  import { router } from '@inertiajs/vue3'

  router.visit('/another-page', { viewTransition: true })

  router.visit('/another-page', {
      viewTransition: (transition) => {
          transition.ready.then(() => console.log('Transition ready'))
          transition.updateCallbackDone.then(() => console.log('DOM updated'))
          transition.finished.then(() => console.log('Transition finished'))
      },
  })

  <Link href="/another-page" view-transition>Navigate</Link>

  <Link
      href="/another-page"
      :view-transition="(transition) => transition.finished.then(() => console.log('Done'))"
  >
      Navigate
  </Link>
  ```

  - Configuring Defaults

  ```jsx
  import { createInertiaApp } from '@inertiajs/vue3'

  createInertiaApp({
      // ...
      defaults: {
          visitOptions: (href, options) => {
              return { viewTransition: true }
          },
      },
  })
  ```

  - Customizing Transitions

  ```css
  @keyframes fade-in {
      from { opacity: 0; }
  }
  @keyframes fade-out {
      to { opacity: 0; }
  }
  @keyframes slide-from-right {
      from { transform: translateX(30px); }
  }
  @keyframes slide-to-left {
      to { transform: translateX(-30px); }
  }
  ::view-transition-old(root) {
      animation: 90ms cubic-bezier(0.4, 0, 1, 1) both fade-out,
      300ms cubic-bezier(0.4, 0, 0.2, 1) both slide-to-left;
  }
  ::view-transition-new(root) {
      animation: 210ms cubic-bezier(0, 0, 0.2, 1) 90ms both fade-in,
      300ms cubic-bezier(0.4, 0, 0.2, 1) both slide-from-right;
  }
  ```

  ```jsx
  <!-- Profile.vue -->
  <template>
      <img src="/avatar.jpg" alt="User" class="avatar-large" />
  </template>

  <style>
  .avatar-large {
      view-transition-name: user-avatar;
      width: auto;
      height: 200px;
  }
  </style>

  <!-- Dashboard.vue -->
  <template>
      <img src="/avatar.jpg" alt="User" class="avatar-small" />
  </template>

  <style>
  .avatar-small {
      view-transition-name: user-avatar;
      width: auto;
      height: 40px;
  }
  </style>
  ```

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

  When making visits to the same page, it's not always necessary to re-fetch all of the page's data. In fact, selecting only a subset of the data can be a helpful performance optimization. Inertia makes this possible via its "partial reload" feature. Inertia automatically merge the partial data returned from the server with the data it already has in memory client-side. Partial reloads only work for visits made to the same page component.

  ```js
  import { router } from '@inertiajs/vue3'

  router.visit(url, {
      only: ['users'], // specify which props the server should return
  })

  router.visit(url, {
      except: ['users'], // specify which props the server should exclude
  })

  router.reload({ only: ['users'] }) // automatically uses the current URL

  <Link href="/users?active=true" :only="['users']">Show active</Link>
  ```

  - Lazy Data Evaluation (Server Side)

  For partial reloads to be most effective, be sure to also use **lazy data evaluation** when returning props from your **server-side** routes or controllers. This can be accomplished by wrapping all optional page data in a **closure**.

  ```php
  return Inertia::render('Users/Index', [
      'users' => fn () => User::all(),
      'companies' => fn () => Company::all(),
  ]);
  ```

  When Inertia performs a request, it will determine which data is required and only then will it evaluate the closure. This can significantly increase the performance of pages that contain a lot of optional data.

  Additionally, Inertia provides an `Inertia::optional()` method to specify that a prop should never be included unless explicitly requested using the `only` option:

  ```php
  return Inertia::render('Users/Index', [
      'users' => Inertia::optional(fn () => User::all()),
  ]);
  ```

  On the inverse, you can use the `Inertia::always()` method to specify that a prop should always be included, even if it has not been explicitly required in a partial reload.

  ```php
  return Inertia::render('Users/Index', [
      'users' => Inertia::always(User::all()),
  ]);
  ```

- ### **Deferred props**

  Inertia's deferred props feature allows you to defer the loading of certain page data until after the initial page render. This can be useful for improving the perceived performance of your app by allowing the initial page render to happen as quickly as possible.

  - Server Side

  To defer a prop, you can use the `Inertia::defer()` method when returning your response. This method receives a callback that returns the prop data. The callback will be executed in a **separate request** after the initial page render.

  ```php
  Route::get('/users', function () {
      return Inertia::render('Users/Index', [
          'users' => User::all(),
          'roles' => Role::all(),
          'permissions' => Inertia::defer(fn () => Permission::all()),
      ]);
  });
  ```

  By default, all deferred props get fetched in one request after the initial page is rendered, but you can choose to fetch data in parallel by grouping props together.

  ```php
  Route::get('/users', function () {
      return Inertia::render('Users/Index', [
          'users' => User::all(),
          'roles' => Role::all(),
          'permissions' => Inertia::defer(fn () => Permission::all()),
          'teams' => Inertia::defer(fn () => Team::all(), 'attributes'),
          'projects' => Inertia::defer(fn () => Project::all(), 'attributes'),
          'tasks' => Inertia::defer(fn () => Task::all(), 'attributes'),
      ]);
  });
  ```

  In the example above, the `teams`, `projects`, and `tasks` props will be fetched in one request, while the `permissions` prop will be fetched in a separate request in parallel. **Group names** are arbitrary strings and can be anything you choose.

  - Client Side

  On the client side, Inertia provides the `Deferred` component to help you manage deferred props. This component will automatically wait for the specified deferred props to be available before rendering its children.

  ```jsx
  <script setup>
  import { Deferred } from '@inertiajs/vue3'
  </script>

  <template>
      <Deferred data="permissions"> // Could be an array => :data="['teams', 'users']"
          <template #fallback>
              <div>Loading...</div>
          </template>

          <div v-for="permission in permissions">
              <!-- ... -->
          </div>
      </Deferred>
  </template>
  ```

- ### **Merging props**

  Inertia overwrites props with the same name when reloading a page. However, you may need to merge new data with existing data instead. For example, when implementing a "load more" button for paginated results. The Infinite scroll component uses prop merging under the hood.

  Prop merging only works during `partial reloads`. `Full page visits will always replace props` entirely, even if you've marked them for merging.

  - Merge Methods

  To merge a prop instead of overwriting it, you may use the `Inertia::merge()` method when returning your response.

  ```php
  Route::get('/items', function () {
      // Static array of tags...
      $allTags = [
          'Laravel', 'React', 'Vue', 'Tailwind', 'Inertia',
          'PHP', 'JavaScript', 'TypeScript', 'Docker', 'Vite',
      ];

      // Get chunk of tags by page...
      $page = request()->input('page', 1);
      $perPage = 5;
      $offset = ($page - 1) * $perPage;
      $tags = array_slice($allTags, $offset, $perPage);

      return Inertia::render('Tags/Index', [
          'tags' => Inertia::merge($tags),
      ]);
  });
  ```

  The `Inertia::merge()` method will append new items to existing arrays at the root level. You may change this behavior to prepend items instead.

  ```php
  // Append at root level (default)...
  Inertia::merge($items);

  // Prepend at root level...
  Inertia::merge($items)->prepend();
  ```

  For more precise control, you can target specific nested properties for merging while replacing the rest of the object.

  ```php
  // Only append to the 'data' array, replace everything else...
  Inertia::merge(User::paginate())->append('data');

  // Prepend to the 'messages' array...
  Inertia::merge($chatData)->prepend('messages');
  ```

  You can combine multiple operations and target several properties at once.

  ```php
  Inertia::merge($forumData)
      ->append('posts')
      ->prepend('announcements');

  // Target multiple properties...
  Inertia::merge($dashboardData)
      ->append(['notifications', 'activities']);
  ```

  - Matching Items

  When merging arrays, you may use the `matchOn` parameter to match existing items by a specific field and update them instead of appending new ones.

  ```php
  // Match posts by ID, update existing ones...
  Inertia::merge($postData)->append('data', matchOn: 'id');

  // Multiple properties with different match fields...
  Inertia::merge($complexData)->append([
      'users.data' => 'id',
      'messages' => 'uuid',
  ]);
  ```

  - Deep Merge

  Instead of specifying which nested paths should be merged, you may use `Inertia::deepMerge()`to ensure a deep merge of the entire structure.

  ```php
  Route::get('/chat', function () {
      $chatData = [
          'messages' => [
              ['id' => 4, 'text' => 'Hello there!', 'user' => 'Alice'],
              ['id' => 5, 'text' => 'How are you?', 'user' => 'Bob'],
          ],
          'online' => 12,
      ];

      return Inertia::render('Chat', [
          'chat' => Inertia::deepMerge($chatData)->matchOn('messages.id'),
      ]);
  });
  ```

  `Inertia::deepMerge()` was introduced before `Inertia::merge()` had support for prepending and targeting nested paths. In most cases, `Inertia::merge()` with its append and prepend methods should be sufficient.

  - Combining with Deferred Props

  You can also combine `deferred props`] with mergeable props to defer the loading of the prop and ultimately mark it as mergeable once it's loaded.

  ```php
  Route::get('/users', function () {
      $page = request()->input('page', 1);
      $perPage = request()->input('per_page', 10);

      return Inertia::render('Users/Index', [
          'results' => Inertia::defer(fn() => User::paginate($perPage, page: $page))->deepMerge(),
      ]);
  });
  ```

  - Resetting Props

  On the client side, you can indicate to the server that you would like to reset the prop. This is useful when you want to clear the prop value before merging new data, such as when the user enters a new search query on a paginated list. The `reset` request option accepts an array of the props keys you would like to reset.

  ```js
  router.reload({
      reset: ['results'],
      // ...
  })
  ```

- ### **Polling**

  ```jsx
  import { usePoll } from '@inertiajs/vue3'

  usePoll(2000)

  // you can pass any of the router.reload options as the second parameter
  usePoll(2000, {
    data: {},
    replace: false,
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
  ```

  ```jsx
  <script setup>
  import { usePoll } from '@inertiajs/vue3'

  const { start, stop } = usePoll(2000, {}, {
      autoStart: false,
  })
  </script>

  <template>
      <button @click="start">Start polling</button>
      <button @click="stop">Stop polling</button>
  </template>
  ```

- ### **Prefetching**

  Inertia supports prefetching data for pages that are likely to be visited next. This can be useful for improving the perceived performance of your app by allowing the data to be fetched in the background while the user is still interacting with the current page.

  - Link Prefetching

  You can add the `prefetch` prop to the Inertia link component. By default, Inertia will prefetch the data for the page when the user hovers over the link for more than `75ms`. You may customize this hover delay by setting the `prefetch.hoverDelay` option in your application defaults.

  By default, data is cached for `30 seconds` before being evicted. You may customize this default value by setting the `prefetch.cacheFor` option in your application defaults. You may also customize the cache duration on a per-link basis by passing a `cacheFor` prop to the `Link` component.

  ```jsx
  import { Link } from '@inertiajs/vue3'

  <Link href="/users" prefetch>Users</Link>

  <Link href="/users" prefetch cache-for="1m">Users</Link>
  <Link href="/users" prefetch cache-for="10s">Users</Link>
  <Link href="/users" prefetch :cache-for="5000">Users</Link>

  // you can also start prefetching on `mousedown` by passing the `click` value
  <Link href="/users" prefetch="click">Users</Link>

  // you can prefetch the data on mount as well
  <Link href="/users" prefetch="mount">Users</Link>
  ```

  - Programmatic Prefetching

  You can prefetch data programmatically using `router.prefetch`. This method's signature is identical to `router.visit` with the exception of a third argument that allows you to specify prefetch options. When the `cacheFor` option is not specified, it defaults to 30 seconds.

  ```js
  router.prefetch(
      '/users',
      { method: 'get', data: { page: 2 } },
  )

  router.prefetch(
      '/users',
      { method: 'get', data: { page: 2 } },
      { cacheFor: '1m' },
  )
  ```

  Inertia also provides a `usePrefetch` hook that allows you to track the prefetch state for the current page. It returns information about whether the page is currently prefetching, has been prefetched, when it was last updated, and a `flush` method that flushes the cache for the current page only.

  ```js
  import { usePrefetch } from '@inertiajs/vue3'

  const { lastUpdatedAt, isPrefetching, isPrefetched, flush } = usePrefetch()
  ```

  You can also pass visit options when you need to differentiate between different request configurations for the same URL.

  ```js
  import { usePrefetch } from '@inertiajs/vue3'

  const { lastUpdatedAt, isPrefetching, isPrefetched, flush } = usePrefetch({
      headers: { 'X-Custom-Header': 'value' }
  })
  ```

  - Cache Tags

  Cache tags allow you to group related prefetched data and invalidate all cached data with that tag when specific events occur. To tag cached data, pass a `cacheTags` prop to your `Link` component.

  ```jsx
  <script setup>
  import { Link } from '@inertiajs/vue3'
  </script>

  <template>
      <Link href="/users" prefetch cache-tags="users">Users</Link>
      <Link href="/dashboard" prefetch :cache-tags="['dashboard', 'stats']">Dashboard</Link>
  </template>
  ```

  When prefetching programmatically, pass `cacheTags` in the third argument to `router.prefetch`.

  ```js
  router.prefetch('/users', {}, { cacheTags: 'users' })
  router.prefetch('/dashboard', {}, { cacheTags: ['dashboard', 'stats'] })
  ```

  - Cache Invalidation

  You can manually flush the prefetch cache by calling `router.flushAll` to remove all cached data, or `router.flush` to remove cache for a specific page.

  ```js
  // Flush all prefetch cache
  router.flushAll()

  // Flush cache for a specific page
  router.flush('/users', { method: 'get', data: { page: 2 } })

  // Using the usePrefetch hook
  const { flush } = usePrefetch()

  // Flush cache for the current page
  flush()

  // Flush all responses tagged with 'users'
  router.flushByCacheTags('users')

  // Flush all responses tagged with 'dashboard' OR 'stats'
  router.flushByCacheTags(['dashboard', 'stats'])

  // flush all cached data on every navigation
  router.on('navigate', () => router.flushAll())
  ```

  - Invalidate on Requests

  To automatically invalidate caches when making requests, pass an `invalidateCacheTags` prop to the `Form` component. The specified tags will be flushed when the form submission succeeds.

  ```jsx
  <script setup>
  import { Form } from '@inertiajs/vue3'
  </script>

  <template>
      <Form action="/users" method="post" :invalidate-cache-tags="['users', 'dashboard']">
          <input type="text" name="name" />
          <input type="email" name="email" />
          <button type="submit">Create User</button>
      </Form>
  </template>
  ```

  When using the `useForm` helper, you can include `invalidateCacheTags` in the visit options.

  ```js
  import { useForm } from '@inertiajs/vue3'

  const form = useForm({
      name: '',
      email: '',
  })

  const submit = () => {
      form.post('/users', {
          invalidateCacheTags: ['users', 'dashboard']
      })
  }
  ```

  You can also invalidate cache tags with programmatic visits by including `invalidateCacheTags` in the options.

  ```js
  router.delete(`/users/${userId}`, {}, {
      invalidateCacheTags: ['users', 'dashboard']
  })

  router.post('/posts', postData, {
      invalidateCacheTags: ['posts', 'recent-posts']
  })
  ```

  - Stale While Revalidate

  By default, Inertia will fetch a fresh copy of the data when the user visits the page if the cached data is older than the cache duration. You can customize this behavior by passing a tuple to the `cacheFor`prop.

  The first value in the array represents the number of seconds the cache is considered fresh, while the second value defines how long it can be served as stale data before fetching data from the server is necessary.

  ```jsx
  import { Link } from '@inertiajs/vue3'

  <Link href="/users" prefetch :cacheFor="['30s', '1m']">Users</Link>
  ```

  - If a request is made within the fresh period (before the first value), the cache is returned immediately without making a request to the server.
  - If a request is made during the stale period (between the two values), the stale value is served to the user, and a request is made in the background to refresh the cached data. Once the fresh data is returned, it is merged into the page so the user has the most recent data.
  - If a request is made after the second value, the cache is considered expired, and the page and data is fetched from the sever as a regular request.

- ### **Load when visible**

  Inertia supports lazy loading data on scroll using the **Intersection Observer API**. It provides the `WhenVisible` component as a convenient way to load data when an element becomes visible in the viewport.

  The `WhenVisible` component accepts a `data` prop that specifies the **key of the prop to load**. It also accepts a `fallback` prop that specifies a component to render while the data is loading. The `WhenVisible` component should wrap the component that depends on the data.

  ```jsx
  <script setup>
  import { WhenVisible } from '@inertiajs/vue3'
  </script>

  <template>
      <WhenVisible data="permissions"> // to load multiple props you can provide an array => :data="['teams', 'users']"
          <template #fallback>
              <div>Loading...</div>
          </template>

          <div v-for="permission in permissions">
              <!-- ... -->
          </div>
      </WhenVisible>
  </template>
  ```

  To work properly, you should combine this with `Inertia::optional()` method to specify that a prop will be requested `only` later:

  ```php
  return Inertia::render('Users/Index', [
      'permissions' => Inertia::optional(fn () => Permission::all()),
  ]);
  ```

  - Loading Before Visible

  If you'd like to start loading data before the element is visible, you can provide a value to the `buffer` prop. The buffer value is the number of pixels before the element is visible.

  ```jsx
  <script setup>
  import { WhenVisible } from '@inertiajs/vue3'
  </script>

  <template>
      <WhenVisible data="permissions" :buffer="500">
          <template #fallback>
              <div>Loading...</div>
          </template>

          <div v-for="permission in permissions">
              <!-- ... -->
          </div>
      </WhenVisible>
  </template>
  ```

  By default, the `WhenVisible` component wraps the fallback template in a `div` element so it can ensure the element is visible in the viewport. If you want to customize the wrapper element, you can provide the `as` prop.

  ```jsx
  <script setup>
  import { WhenVisible } from '@inertiajs/vue3'
  </script>

  <template>
      <WhenVisible data="products" as="span">
          <!-- ... -->
      </WhenVisible>
  </template>
  ```

  - Always Trigger

  By default, the `WhenVisible` component will only trigger once when the element becomes visible. If you want to always trigger the data loading when the element is visible, you can provide the `always`prop.

  Note that if the data loading request is already in flight, the component will wait until it is finished to start the next request if the element is still visible in the viewport.

  ```jsx
  <script setup>
  import { WhenVisible } from '@inertiajs/vue3'
  </script>

  <template>
      <WhenVisible data="products" always>
          <!-- ... -->
      </WhenVisible>
  </template>
  ```

  Always could be associated to a prop or computed value. You can pass the prop `params`, a object containing the parameters to send with the request. These parameters are the same as what you would normally pass to router.reload.

  ```
  params="{
    data: {},
    only: [],
    except: [],
    headers: {},
    onError: errors => {},
  }"
  ```

  ```jsx
  <script setup>
  import { WhenVisible, computed } from '@inertiajs/vue3'

  const reachedEnd = computed(() => {
    return props.pagination.current_page >= pros.pagination.last_page;
  });
  </script>

  <template>
    <WhenVisible
      :always="!reachedEnd"
      :params="{
        only: ['courses', 'pagination'],
        data: {
          page: pagination.current_page + 1
        }
      }"
      >
      <template #fallback>
        <span>Loading more...</span>
      </template>
    </WhenVisible>
  </template>
  ```

  - Form Submissions

  When submitting forms, you may want to use the `except` option to exclude the props that are being used by the `WhenVisible` component. This prevents the props from being reloaded when you get redirected back to the current page because of validation errors.

  ```jsx
  <script setup>
  import { useForm, WhenVisible } from '@inertiajs/vue3'

  const form = useForm({
      name: '',
      email: '',
  })

  function submit() {
      form.post('/users', {
          except: ['permissions'],
      })
  }
  </script>

  <template>
      <form @submit.prevent="submit">
          <!-- ... -->
      </form>

      <WhenVisible data="permissions">
          <!-- ... -->
      </WhenVisible>
  </template>
  ```

- ### **Infinite Scroll**

  - Server-Side

  You should use the `Inertia::scroll()`method when returning your response. This method automatically configures the proper merge behavior and normalizes pagination metadata for the frontend component.

  ```php
  Route::get('/users', function () {
      return Inertia::render('Users/Index', [
          'users' => Inertia::scroll(fn () => User::paginate())
      ]);
  });
  ```

  - Client-Side

  Inertia provides the `<InfiniteScroll>` component to automatically load additional pages of content. The component accepts a `data` prop that specifies the key of the prop containing your paginated data. The `<InfiniteScroll>` component should wrap the content that depends on the paginated data.

  ```jsx
  <script setup>
  import { InfiniteScroll } from '@inertiajs/vue3'

  defineProps(['users'])
  </script>

  <template>
      <InfiniteScroll data="users">
          <div v-for="user in users.data" :key="user.id">
              {{ user.name }}
          </div>
      </InfiniteScroll>
  </template>
  ```

  The component uses [intersection observers ](https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API) to detect when users scroll near the end of the content and automatically triggers requests to load the next page. New data is merged with existing content rather than replacing it.

  - Loading Buffer

  You can control how early content begins loading by setting a buffer distance. The buffer specifies how many pixels before the end of the content loading should begin.

  ```jsx
  <InfiniteScroll data="users" :buffer="500">
      <!-- ... -->
  </InfiniteScroll>
  ```

  - URL Synchronization

  The infinite scroll component updates the browser URL's query string (`?page=...`) as users scroll through content. The URL reflects which page has the most visible items on screen, updating in both directions as users scroll up or down. This allows users to bookmark or share links to specific pages. You can disable this behavior to maintain the original page URL.

  ```jsx
  <InfiniteScroll data="users" preserve-url>
      <!-- ... -->
  </InfiniteScroll>
  ```

  This is useful when infinite scroll is used for secondary content that shouldn't affect the main page URL, such as comments on a blog post or related products on a product page.

  - Resetting

  When filters or other parameters change, you may need to reset the infinite scroll data to start from the beginning. Without resetting, new results will merge with existing content instead of replacing it. You can reset data using the `reset` visit option.

  ```jsx
  <script setup>
  import { router } from '@inertiajs/vue3'

  const show = (role) => {
      router.visit(route('users'), {
          data: { filter: { role } },
          only: ['users'],
          reset: ['users'],
      })
  }
  </script>

  <template>
      <button @click="show('admin')">Show admins</button>
      <button @click="show('customer')">Show customers</button>

      <InfiniteScroll data="users">
          <div v-for="user in users.data" :key="user.id">
              {{ user.name }}
          </div>
      </InfiniteScroll>
  </template>
  ```

  - Loading Direction

  The infinite scroll component loads content in both directions when you scroll near the start or end. You can control this behavior using the `only-next` and `only-previous` props.

  ```jsx
  <!-- Only load the next page -->
  <InfiniteScroll data="users" only-next>
      <!-- ... -->
  </InfiniteScroll>

  <!-- Only load the previous page -->
  <InfiniteScroll data="messages" only-previous>
      <!-- ... -->
  </InfiniteScroll>

  <!-- Load in both directions (default) -->
  <InfiniteScroll data="posts">
      <!-- ... -->
  </InfiniteScroll>
  ```

  - Reverse Mode

  For chat applications, timelines, or interfaces where content is sorted descendingly (newest items at the bottom), you can enable reverse mode. This configures the component to load older content when scrolling upward.

  ```jsx
  <InfiniteScroll data="messages" reverse>
      <!-- ... -->
  </InfiniteScroll>
  ```

  In reverse mode, the component flips the loading directions so that scrolling up loads the next page (older content) and scrolling down loads the previous page (newer content). The component handles the loading positioning, but you are responsible for reversing your content to display in the correct order.

  Reverse mode also enables automatic scrolling to the bottom on initial load, which you can disable with `:auto-scroll="false"`.

  ```jsx
  <InfiniteScroll data="messages" reverse :auto-scroll="false">
      <!-- ... -->
  </InfiniteScroll>
  ```

  - Default Slot

  The main content area where you render your data items. This slot receives loading state information.

  ```jsx
  <InfiniteScroll data="users" #default="{ loading, loadingPrevious, loadingNext }">
      <!-- Your content with access to loading states -->
  </InfiniteScroll>
  ```
  - Loading Slot

  The loading slot is used as a fallback when loading content and no custom `before` or `after` slots are provided. This creates a default loading indicator.

  ```jsx
  <template>
      <InfiniteScroll data="users">
          <!-- Your content -->

          <template #loading>
              Loading more users...
          </template>
      </InfiniteScroll>
  </template>
  ```

  - Previous and Next Slots

  The `previous` and `next` slots are rendered above and below the main content, typically used for manual load controls. These slots receive several properties including loading states, fetch functions, and mode indicators.

  ```jsx
  <template>
      <InfiniteScroll data="users" :manual-after="3">
          <template #previous="{ loading, fetch, hasMore, manualMode }">
              <button v-if="manualMode && hasMore" @click="fetch" :disabled="loading">
                  {{ loading ? 'Loading...' : 'Load previous' }}
              </button>
          </template>

          <!-- Your content -->

          <template #next="{ loading, fetch, hasMore, manualMode }">
              <button v-if="manualMode && hasMore" @click="fetch" :disabled="loading">
                  {{ loading ? 'Loading...' : 'Load more' }}
              </button>
          </template>
      </InfiniteScroll>
  </template>
  ```

  The `loading`, `previous`, and `next` slots receive the following properties:

  | Property          | Description                                    |
  | :---------------- | :--------------------------------------------- |
  | `loading`         | Whether the slot is currently loading content  |
  | `loadingPrevious` | Whether previous content is loading            |
  | `loadingNext`     | Whether next content is loading                |
  | `fetch`           | Function to trigger loading for the slot       |
  | `hasMore`         | Whether more content is available for the slot |
  | `hasPrevious`     | Whether more previous content is available     |
  | `hasNext`         | Whether more next content is available         |
  | `manualMode`      | Whether manual mode is active                  |
  | `autoMode`        | Whether automatic loading is active            |

  - Custom Element

  The `InfiniteScroll` component renders as a `<div>` element. You may customize this to use any HTML element using the `as` prop.

  ```jsx
  <template>
      <InfiniteScroll data="products" as="ul">
          <li v-for="product in products.data" :key="product.id">
              {{ product.name }}
          </li>
      </InfiniteScroll>
  </template>
  ```

  - Scroll Containers

  The infinite scroll component works within any scrollable container, not just the main document. The component automatically adapts to use the custom scroll container for trigger detection and calculations instead of the main document scroll.

  ```jsx
  <template>
      <div style="height: 400px; overflow-y: auto;">
          <InfiniteScroll data="users">
              <div v-for="user in users.data" :key="user.id">
                  {{ user.name }}
              </div>
          </InfiniteScroll>
      </div>
  </template>
  ```

  - Multiple Scroll Containers

  Sometimes you may need to render multiple infinite scroll components on a single page. However, if both components use the default `page` query parameter for URL synchronization, they will conflict with each other. To resolve this, instruct each paginator to use a custom `pageName`.

  ```php
  Route::get('/dashboard', function () {
      return Inertia::render('Dashboard', [
          'users' => Inertia::scroll(
              fn() => User::paginate(pageName: 'users')
          ),
          'orders' => Inertia::scroll(
              fn() => Order::paginate(pageName: 'orders')
          ),
      ]);
  });
  ```

  The `Inertia::scroll()` method automatically detects the `pageName` from each paginator, allowing both scroll containers to maintain independent pagination state. This results in URLs like `?users=2&orders=3` instead of conflicting `?page=` parameters.

  For more information about pagination page names, see [Laravel's documentation](https://laravel.com/docs/pagination#multiple-paginator-instances-per-page).

- ### **Remembering state**

  When navigating browser history, Inertia restores pages using prop data cached in history state. However, Inertia does not restore local page component state. For example, if a user partially completes a form, then navigates away, and then returns back, the form will be reset and their work will be lost. To mitigate this issue, you can tell Inertia which local component state to save in the browser history.

  - Saving Local State

  To save local component state to the history state, use the `useRemember` feature to tell Inertia which data it should remember.

  ```jsx
  import { useRemember } from '@inertiajs/vue3'

  const form = useRemember({
      first_name: null,
      last_name: null,
  })
  ```

  Now, whenever your local `form` state changes, Inertia will automatically save this data to the history state and will also restore it on history navigation.

  - Multiple Components

  If your page contains multiple components that use the remember functionality provided by Inertia, you need to provide a unique key for each component so that Inertia knows which data to restore to each component.

  ```jsx
  import { useRemember } from '@inertiajs/vue3'

  const form = useRemember({
      first_name: null,
      last_name: null,
  }, 'Users/Create')
  ```

  If you have multiple instances of the same component on the page using the remember functionality, be sure to also include a unique key for each component instance, such as a model identifier.

  ```jsx
  import { useRemember } from '@inertiajs/vue3'

  const props = defineProps({ user: Object })

  const form = useRemember({
      first_name: null,
      last_name: null,
  }, `Users/Edit:${props.user.id}`)
  ```

  - Form Helper

  If you're using the Inertia form helper, you can pass a unique form key as the first argument when instantiating your form. This will cause the form data and errors to automatically be remembered.

  ```jsx
  import { useForm } from '@inertiajs/vue3'

  const form = useForm('CreateUser', data)
  const form = useForm(`EditUser:${props.user.id}`, data)
  ```

  - Manually Saving State

  ```jsx
  import { router } from '@inertiajs/vue3'

  // Save local component state to history state
  router.remember(data, 'my-key')

  // Restore local component state from history state
  let data = router.restore('my-key')
  ```

- ## **Security**

- ### **Authentication**

  This is managed by the server-side framework.

- ### **Authorization**

  It is handled by the server-side authorization policies. However, you may be wondering how to perform checks against your authorization policies from within your Inertia page components since you won't have access to your framework's server-side helpers. The simplest approach to solving this problem is to pass the results of your authorization checks as props to your page components.

  ```php
  class UsersController extends Controller
  {
      public function index()
      {
          return Inertia::render('Users/Index', [
              'can' => [
                  'create_user' => Auth::user()->can('create', User::class),
              ],
              'users' => User::all()->map(function ($user) {
                  return [
                      'first_name' => $user->first_name,
                      'last_name' => $user->last_name,
                      'email' => $user->email,
                      'can' => [
                          'edit_user' => Auth::user()->can('edit', $user),
                      ]
                  ];
              }),
          ]);
      }
  }
  ```

- ### **CSRF protection**

  Laravel automatically includes the proper CSRF token when making requests via Inertia or Axios. However, if you’re using Laravel, be sure to omit the csrf-token meta tag from your project, as this will prevent the CSRF token from refreshing properly.

  Axios includes a CSRF functionality. Axios is the HTTP library that Inertia uses under the hood.
  Axios automatically checks for the existence of an XSRF-TOKEN cookie. If it’s present, it will then include the token in an X-XSRF-TOKEN header for any requests it makes.

  The easiest way to implement this is using server-side middleware. Simply include the XSRF-TOKENcookie on each response, and then verify the token using the X-XSRF-TOKEN header sent in the requests from axios.

- ### **History encryption**

  Imagine a scenario where your user is authenticated, browses privileged information on your site, then logs out. If they press the back button, they can still see the privileged information that is stored in the window's history state. This is a security risk. To prevent this, Inertia.js provides a history encryption feature.

  - How It Works

  When you instruct Inertia to encrypt your app's history, it uses the browser's built-in [`crypto` api ](https://developer.mozilla.org/en-US/docs/Web/API/Crypto) to encrypt the current page's data before pushing it to the history state. We store the corresponding key in the browser's session storage. When the user navigates back to a page, we decrypt the data using the key stored in the session storage.

  Once you instruct Inertia to clear your history state, we simply clear the existing key from session storage roll a new one. If we attempt to decrypt the history state with the new key, it will fail and Inertia will make a fresh request back to your server for the page data.

  History encryption relies on `window.crypto.subtle` which is only available in secure environments (sites with SSL enabled).

  - Opting in

  History encryption is an opt-in feature. There are several methods for enabling it:

  - Global Encryption

  If you'd like to enable history encryption globally, set the `inertia.history.encrypt` config value to `true`.

  You are able to opt out of encryption on specific pages by calling the `Inertia::encryptHistory()`method before returning the response.

  ```php
  Inertia::encryptHistory(false);
  ```

  - Per-request Encryption

  To encrypt the history of an individual request, simply call the `Inertia::encryptHistory()` method before returning the response.

  ```php
  Inertia::encryptHistory();
  ```

  - Encrypt Middleware

  To encrypt a group of routes, you may use Inertia's included `EncryptHistory` middleware.

  ```php
  Route::middleware([Inertia\Middleware\EncryptHistory::class])->get('/', function() {
      //
  });

  Route::middleware(['inertia::encrypt'])->get('/', function() {
      //
  });
  ```

  - Clearing History

  To clear the history state, you can call the `Inertia::clearHistory()` method before returning the response.

  ```php
  Inertia::clearHistory();
  ```

  Once the response has rendered on the client, the encryption key will be rotated, rendering the previous history state unreadable.

  You can also clear history on the client site by calling `router.clearHistory()`.

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

  ```php
  use Illuminate\Http\Request;
  use Symfony\Component\HttpFoundation\Response;
  use Inertia\Inertia;

  ->withExceptions(function (Exceptions $exceptions) {
      $exceptions->respond(function (Response $response, Throwable $exception, Request $request) {
          if (! app()->environment(['local', 'testing']) && in_array($response->getStatusCode(), [500, 503, 404, 403])) {
              return Inertia::render('ErrorPage', ['status' => $response->getStatusCode()])
                  ->toResponse($request)
                  ->setStatusCode($response->getStatusCode());
          }

          if ($response->getStatusCode() === 419) {
              return back()->with([
                  'message' => 'The page expired, please try again.',
              ]);
          }

          return $response;
      });
  })
  ```

- ### **Events**

  ```jsx
  import { router } from '@inertiajs/vue3'

  router.on('start', (event) => {
      console.log(`Starting a visit to ${event.detail.visit.url}`)
  })

  document.addEventListener('inertia:start', (event) => {
      console.log(`Starting a visit to ${event.detail.visit.url}`)
  })

  let removeStartEventListener = router.on('start', (event) => {
      console.log(`Starting a visit to ${event.detail.visit.url}`)
  })

  // Remove the listener...
  removeStartEventListener()

  onUnmounted(
      router.on('start', (event) => {
          console.log(`Starting a visit to ${event.detail.visit.url}`)
      })
  )

  let startEventListener = (event) => {
      console.log(`Starting a visit to ${event.detail.visit.url}`)
  }

  document.addEventListener('inertia:start', startEventListener)

  // Remove the listener...
  document.removeEventListener('inertia:start', startEventListener)

  router.on('before', (event) => {
      if (!confirm('Are you sure you want to navigate away?')) {
          event.preventDefault()
      }
  })

  router.on('before', (event) => {
      // cancel the event by returning false
      return confirm('Are you sure you want to navigate away?')
  })

  router.on('before', (event) => {
      console.log(`About to make a visit to ${event.detail.visit.url}`)
  })

  router.on('before', (event) => {
      return confirm('Are you sure you want to navigate away?')
  })

  router.on('start', (event) => {
      console.log(`Starting a visit to ${event.detail.visit.url}`)
  })

  router.on('progress', (event) => {
      this.form.progress = event.detail.progress.percentage
  })

  router.on('success', (event) => {
      console.log(`Successfully made a visit to ${event.detail.page.url}`)
  })

  router.on('error', (errors) => {
      console.log(errors)
  })

  router.on('invalid', (event) => {
      console.log(`An invalid Inertia response was received.`)
      console.log(event.detail.response)
  })

  router.on('invalid', (event) => {
      event.preventDefault()

      // Handle the invalid response yourself...
  })

  router.on('exception', (event) => {
      console.log(`An unexpected error occurred during an Inertia visit.`)
      console.log(event.detail.error)
  })

  router.on('exception', (event) => {
      event.preventDefault()
      // Handle the error yourself
  })

  router.on('finish', (event) => {
      NProgress.done()
  })

  router.on('navigate', (event) => {
      console.log(`Navigated to ${event.detail.page.url}`)
  })

  router.on('prefetching', (event) => {
      console.log(`Prefetching ${event.detail.page.url}`)
  })

  router.on('prefetched', (event) => {
      console.log(`Prefetched ${event.detail.page.url}`)
  })
  ```

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

  ```php
  use Inertia\Testing\AssertableInertia as Assert;

  class PodcastsControllerTest extends TestCase
  {
      public function test_can_view_podcast()
      {
          $this->get('/podcasts/41')
              ->assertInertia(fn (Assert $page) => $page
                  ->component('Podcasts/Show')
                  ->has('podcast', fn (Assert $page) => $page
                      ->where('id', $podcast->id)
                      ->where('subject', 'The Laravel Podcast')
                      ->where('description', 'The Laravel Podcast brings you Laravel and PHP development news and discussion.')
                      ->has('seasons', 4)
                      ->has('seasons.4.episodes', 21)
                      ->has('host', fn (Assert $page) => $page
                          ->where('id', 1)
                          ->where('name', 'Matt Stauffer')
                      )
                      ->has('subscribers', 7, fn (Assert $page) => $page
                          ->where('id', 2)
                          ->where('name', 'Claudio Dekker')
                          ->where('platform', 'Apple Podcasts')
                          ->etc()
                          ->missing('email')
                          ->missing('password')
                      )
                  )
              );
      }
  }
  ```
