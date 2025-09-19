- **[Laravel Pint](https://github.com/laravel/pint)**
  - composer global require laravel/pint
  - [Visual Studio Code Extension](https://marketplace.visualstudio.com/items?itemName=evgenius33.laravel-pint-fixer)
  ```json
  {
    "[php]": {
        "editor.defaultFormatter": "evgenius33.laravel-pint-fixer"
    },
    "laravel-pint-fixer.pintBinPath": "~/.composer/vendor/bin/pint",
    "laravel-pint-fixer.pintConfigPath": "/Users/pascual/Herd/pint.json"
  }
  ```
  - ~/Herd/pint.json
  ```json
  {
    "preset": "laravel"
  }
  ```

- **[PHPStan](https://github.com/phpstan/phpstan) and [Larastan](https://github.com/larastan/larastan)**
  - composer global require phpstan/phpstan
  - composer config --global --list // Check bin-dir
  - Add to ~/.zshrc
      - export PATH="/Users/pascual/.composer/vendor/bin":$PATH
  - Run source ~/.zshrc
  - composer global require larastan/larastan
  - [Visual Studio Code Extension](https://marketplace.visualstudio.com/items?itemName=SanderRonde.phpstan-vscode)
  ```json
  {
      "phpstan.binCommand": [
          "~/.composer/vendor/bin/phpstan"
      ],
      "phpstan.checkValidity": true,
      "phpstan.configFile": "~/Herd/phpstan.neon,phpstan.neon,phpstan.neon.dist,phpstan.dist.neon",
      "phpstan.memoryLimit": "2G",
  }
  ```
  - ~/Herd/phpstan.neon
  ```
  includes:
      - %rootDir%/../../larastan/larastan/extension.neon
      - %rootDir%/../../nesbot/carbon/extension.neon

  parameters:
      level: 5
      paths:
      - %currentWorkingDirectory%/app/
  ```
  - Spawning PHPStan with the following configuration:
  ```json
  {
      "binStr": "/Users/pascual/.composer/vendor/bin/phpstan",
      "args": [
        "analyse",
        "-c",
        "/Users/pascual/Herd/phpstan.neon",
        "--error-format=json",
        "--no-interaction",
        "--memory-limit=2G"
      ]
  }
  ```
  - Spawning PHPStan, command:
  ```bash
  /Users/pascual/.composer/vendor/bin/phpstan "analyse" "-c" "/Users/pascual/Herd/phpstan.neon" "--error-format=json" "--no-interaction" "--memory-limit=2G"
  ```

- **[Rector](https://github.com/rectorphp/rector)**
  - composer global require rector/rector
  - composer global require driftingly/rector-laravel
  - /Users/pascual/Herd/rector.php
  ```php
  <?php

  declare(strict_types=1);

  use Rector\Config\RectorConfig;
  use RectorLaravel\Set\LaravelSetProvider;

  return RectorConfig::configure()
      ->withPaths([
          './app',
          './config',
          './database',
          './routes'
      ])
      ->withPhpSets()
      ->withTypeCoverageLevel(1)
      ->withDeadCodeLevel(1)
      ->withCodeQualityLevel(1)
      ->withSetProviders(LaravelSetProvider::class)
      ->withComposerBased(laravel: true, /** other options */);
  ```
  - rector process --dry-run --config=/Users/pascual/Herd/rector.php
