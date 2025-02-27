# Add custom icons

## Overview

In this guide you will learn how to use the icon renderer component as well as adding custom icons.

{% hint style="info" %}
Even if this is originally a plugin guide, everything will work perfectly in a theme as well. Actually, a theme even is a kind of plugin. So don't get confused by us talking about plugins here.
{% endhint %}

## Prerequisites

In order to follow this guide easily, you first need to have a functioning plugin installed. Head over to our [plugin base guide](../plugin-base-guide.md) to create a plugin, if you don't know how it's done yet. Also knowing and understanding SCSS will be quite mandatory to fully understand what's going on here. Furthermore, it might be helpful to read the guide on how to [handle own assets](add-custom-assets.md) in your plugin before you start with this one.

## Adding icon

In order to add any icons to the Storefront, you use our `sw_icon` twig action. This way, an icon of choice is displayed in the Storefront.

Needless to say, the first step is saving your image somewhere in your plugin where Shopware can find it. The default path for icons is the following:

```text
<YourPlugin>/src/Resources/app/storefront/dist/assets/icon/default
`
```

You can also provide "solid" icons or any other custom pack names which can be configured later with the `pack` parameter. You can do that by creating a folder with the pack name:

```text
<YourPlugin>/src/Resources/app/storefront/dist/assets/icon/<pack-name>
```

By default, Shopware looks inside the "default" folder.

```text
{% sw_icon 'done-outline-24px' style {
    'namespace': 'TestPlugin'
} %}
```

{% hint style="info" %}
When you want to see all icons available to the storefront by default, see [here](https://github.com/shopware/platform/tree/trunk/src/Storefront/Resources/app/storefront/dist/assets/icon). They are available as `default` and `solid` icon pack.
{% endhint %}

Imagine you want to use the default `checkmark` icon from the `solid` pack. In this case,

You surely want to add your own custom icons. In this case, the `namespace` parameter is the most important one to configure. In there, you need to set the name of the theme in which the icon is searched for by its name.

{% hint style="warning" %}
If you configure no deviating namespace, Shopware will display the Storefront's default icons.
{% endhint %}

However, these are not all of your possibilities of configuration. As you see, you're able to configure even more things. Let's take a look at the `style` object's possible parameters:

| Configuration | Description | Remarks |
| :--- | :--- | :--- |
| `size` | Sets the size of the icon | --- |
| `namespace` | Selection of the namespace of the icon, you can compare it with the source of it | Important configuration if you want to use custom icons. |
| `pack` | Selects the pack of different icons | --- |
| `color` | Sets the color of the icon | --- |
| `class` | Defines a class of the icon | --- |

A simple but fully functional example could look like below:

{% raw %}

```text
{% sw_extends '@Storefront/storefront/base.html.twig' %}

{% block base_body %}

    {# We want to set our own icon here #}
    <h1>Custom icon:</h1>
    {% sw_icon 'done-outline-24px' style {
        'size': 'lg',
        'namespace': 'TestPlugin',
        'pack': 'solid'
    } %}
    {{ parent() }}

{% endblock %}
```

{% endraw %}

{% hint style="danger" %}
Icons or other custom assets are not included in the theme inheritance.
{% endhint %}

Inside your theme, you cannot put an icon in a directory corresponding the core folder structure and expect the core one to be automatically overwritten by it, as you're used to with themes in general.
