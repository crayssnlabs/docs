# Configuration

{% hint style="info" %}
Configurations for apps adhere to the same schema as [Plugin Configurations](../plugins/plugin-fundamentals/add-plugin-configuration.md).
{% endhint %}

To offer configuration possibilities to your users you can provide a `config.xml` file that describes your configuration options. You can find detailed information about the possibilities and the structure of the `config.xml` in the according documentation page. To include a `config.xml` file in your app put it into the `Resources/config` folder:

```text
...
└── DemoApp
      └── Resources
            └── config  
                  └── config.xml
      └── manifest.xml
```

The configuration page will be displayed in the administration under the `Extension store`. For development purposes you can use the administration component to configure plugins to provide configuration for your app, therefore use the URL `{appUrl}/admin##/sw/plugin/settings/{appName}`.

## Reading the configuration values

The configuration values are saved as part of the `SystemConfig` and you can use the key `{appName}.config.{fieldName}` to identify the values. There are two possibilities to access the configuration values from your app. If you need those values on your app-backend server, you can read them over the API. If you need the configuration values in your storefront twig templates you can use the `systemConfig()`-twig function.

### Reading the config over the API

To access your apps configuration over the api make a GET request against the `/api/_action/system-config` route. You have to add the prefix for your configuration as the `domain` query parameter. Optionally you can provide a `SalesChannelId`, if you want to read the values for a specific SalesChannel, as the `salesChannelId` query param. The API call will return a JSON-Object containing all of your configuration values. A sample Request and Response may look like this.

```javascript
// GET /api/_action/system-config?domain=DemoApp.config&salesChannelId=98432def39fc4624b33213a56b8c944d

{
    "DemoApp.config.field1": true,
    "DemoApp.config.field2": "successfully configured"
}
```

{% hint style="warning" %}
Keep in mind that your app needs the `system_config:read` permission to access this API.
{% endhint %}

### Reading the config in templates

Inside twig templates you can use the twig function `config` (see [Shopware Twig functions](../../../resources/references/storefront-reference/twig-function-reference.md)). An example twig template could look like this:

{% raw %}

```twig
{{ config('DemoApp.config.field1') }}
```

{% endraw %}

### Reading the config in app scripts

In app scripts you have access to the [`config` service](../../../../resources/references/app-reference/script-reference/miscellaneous-script-services-reference.md#SystemConfigFacade), that can be used to access config values.

{% hint style="info" %}
Note that app scripts were introduced in Shopware 6.4.8.0, and are not supported in previous versions.
{% endhint %}

The `config` service provides an `app()` method, that can be used to access your app's configuration. When using this method you don't need to provide the `{appName}.config` prefix and your app does not need any additional permissions.
{% raw %}

```twig
{% set configValue = services.config.app('field1') %}
```

{% endraw %}

Additionally, you can use the `get()` method, to access any configuration value and not just the ones of your app.

{% hint style="warning" %}
Keep in mind that your app needs the `system_config:read` permission to use the `config.get()` method.
{% endhint %}

{% raw %}

```twig
{% set configValue = services.config.get('core.listing.productsPerPage') %}
```

{% endraw %}

For a detailed description about app scripts refer to this [guide](./app-scripts/README.md).

For a full description of the `config` service take a look at the [service's reference](../../../resources/references/app-reference/script-reference/miscellaneous-script-services-reference.md#servicesconfig-shopwarecoresystemsystemconfigfacadesystemconfigfacade).
