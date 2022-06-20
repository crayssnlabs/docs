# App Rule Conditions

Your app may introduce custom conditions for use in the [Rule Builder](../../../../concepts/framework/rules.md). Custom conditions can be defined with fields to be rendered in the administration and with their own logic, using the same approach as [App Scripts](../app-scripts/README.md).

{% hint style="info" %}
Note that app rule conditions were introduced in Shopware 6.4.12.0, and are not supported in previous versions.
{% endhint %}

## Definition

App Rule Conditions are defined in the `manifest.xml` file of your app:

{% code title="manifest.xml" %}
```markup
<?xml version="1.0" encoding="UTF-8"?>
<manifest xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="https://raw.githubusercontent.com/shopware/platform/trunk/src/Core/Framework/App/Manifest/Schema/manifest-1.0.xsd">
    <meta>
        ...
    </meta>
    <rule-conditions>
        <rule-condition>
            <identifier>my_custom_condition</identifier>
            <name>Custom condition</name>
            <name lang="de-DE">Eigene Bedingung</name>
            <group>misc</group>
            <script>custom-condition.twig</script>
            <constraints>
                <single-select name="operator">
                    <placeholder>Choose an operator...</placeholder>
                    <placeholder lang="de-DE">Bitte Operatoren wählen</placeholder>
                    <options>
                        <option value="=">
                            <name>Is equal to</name>
                            <name lang="de-DE">Ist gleich</name>
                        </option>
                        <option value="!=">
                            <name>Is not equal to</name>
                            <name lang="de-DE">Ist nicht gleich</name>
                        </option>
                    </options>
                    <required>true</required>
                </single-select>
                <text name="firstName">
                    <placeholder>Enter first name</placeholder>
                    <placeholder lang="de-DE">Bitte Vornamen eingeben</placeholder>
                    <required>true</required>
                </text>
            </constraints>
        </rule-condition>
    </rule-conditions>
</manifest>
```
{% endcode %}

For a complete reference of the structure of the manifest file take a look at the [Manifest reference](../../../../resources/references/app-reference/manifest-reference.md).

Following fields are required:

* `identifier`: A technical name for the condition that should be unique within the scope of the app. The name is being used to identifiy existing conditions when updating the app, so it should not be changed.
* `name`: A descriptive and translatable name for the condition. The name will be shown within the Rule Builder's selection of conditions in the administration.
* `script`: The file name and extension of the file that contains the script for the condition. All scripts for rule conditions must be placed inside `Resources/scripts/rule-conditions` within the root directory of the app.

### Constraints

Constraints are optional and may be used to define fields, whose purpose is to provide data for use within the condition's script.

Constraints are a collection of [custom fields](../custom-data.md), which allows you to provide a variety of different fields for setting parameters within the administration. Fields may be marked as `required`. The `name` attribute of the field is also the variable the field's value will be exposed as within the condition's script. So it is advisable to use a variable-friendly name and to use unique names within the confines of a single condition.

The above example will add the condition shown below for selection in the administration:

![App Rule Condition](../../../../.gitbook/assets/app-rule-condition.png)

## Scripts

The corresponding scripts to the defined conditions within `manifest.xml` need to be placed at specific directory of your app: 

```text
└── DemoApp
    ├── Resources
    │   └── scripts                         // all scripts are stored in this folder
    │       ├── rule-conditions             // reserved for scripts of rule conditions
    │       │   └── custom-condition.twig   // the file name may be freely chosen but must be identical to the corresponding `script` element within `rule-conditions` of `manifest.xml`
    │       └── ...
    └── manifest.xml
```

Scripts for rule conditions are [twig files](https://twig.symfony.com/) that are executed in a sandboxed environment. They offer the same extended syntax and debugging options as [App Scripts](../app-scripts/README.md).

Within the script you will have access to the `scope` variable which is an instance of `RuleScope` as described in the [Rule Builder concept](../../../../concepts/framework/rules.md). The scope instance provides you with the current `SalesChannelContext` and, given the right scope, the current cart. Further available variables depend on the existence of constraints within the definition of your conditions.

A script _must_ return a boolean value, stating whether the condition is true or false. Anything but a boolean returned as value may lead to unexpected behavior.

### Compare helper

To keep conditions scripts smaller we provide a `compare` helper function which can be used for the most common comparisons of two values.

The function takes three arguments:

```text
compare(operator, value, comparable)
```

The `operator` _must_ be one of the following string values: `=`, `!=`, `>`, `>=`, `<`, `<=`, `empty`

If either one or both of `value` and `comparable` are an array, then only `=` and `!=` should be used as operator. It will then compare whether there is at least one occurence of the value within the other array and return `true` if that is the case. For an example `value` might be an ID, `comparable` an array of IDs and you could use the function to match whether the ID is included in that array. 

### Example

{% code title="Resources/scripts/rule-conditions/custom-condition.twig" %}
{% raw %}
```twig
{% if scope.salesChannelContext.customer is not defined %}
    {% return false %}
{% endif %}

{% return compare(operator, scope.salesChannelContext.customer.firstName, firstName) %}
```
{% endraw %}
{% endcode %}

In the example above, we first check whether we can retrieve the current customer from the instance of `RuleScope` and return `false` otherwise.

We then use the variables `operator` and `firstName`, provided by the constraints of the condition, to evaluate whether the first name in question matches the first name of the current customer. To do so we make use of the `compare` helper function.

### Line item condition example

{% code title="manifest.xml" %}
```markup
<!-- ... -->
<rule-condition>
    <identifier>line_item_condition</identifier>
    <name>Custom product multi select</name>
    <group>item</group>
    <script>line-item-condition.twig</script>
    <constraints>
        <single-select name="operator">
            <placeholder>Choose an operator...</placeholder>
            <options>
                <option value="=">
                    <name>Is equal to</name>
                </option>
                <option value="!=">
                    <name>Is not equal to</name>
                </option>
            </options>
            <required>true</required>
        </single-select>
        <multi-entity-select name="productIds">
            <placeholder>Choose products...</placeholder>
            <entity>product</entity>
            <required>true</required>
        </multi-entity-select>
    </constraints>
</rule-condition>
<!-- ... -->
```
{% endcode %}

{% code title="Resources/scripts/rule-conditions/line-item-condition.twig" %}
{% raw %}
```twig
{% if scope.lineItem is defined %}
    {% return compare(operator, lineItem.referenceId, productIds) %}
{% endif %}

{% if scope.cart is not defined %}
    {% return false %}
{% endif %}

{% for lineItem in scope.cart.lineItems.getFlat() %}
    {% if compare(operator, lineItem.referenceId, productIds) %}
        {% return true %}
    {% endif %}
{% endfor %}

{% return false %}
```
{% endraw %}
{% endcode %}

In this example we first check if the current scope is `LineItemScope` and refers to a specific line item. If so we compare that specific line item. Otherwise we check if the scope has a cart and return false if it doesn't. We have a multi select for product selection in the administration which provides an array of product IDs in the script. We iterate the current cart's line items to check if the product is included and return `true` if that is the case.

### Date condition example

{% code title="manifest.xml" %}
```markup
<!-- ... -->
<rule-condition>
    <identifier>date_condition</identifier>
    <name>Custom date condition</name>
    <group>misc</group>
    <script>date-condition.twig</script>
</rule-condition>
<!-- ... -->
```
{% endcode %}

{% code title="Resources/scripts/rule-conditions/date-condition.twig" %}
{% raw %}
```twig
{% return compare('=', scope.getCurrentTime()|date_modify('first day of this month')|date_modify('second wednesday of this month')|date('Y-m-d'), scope.getCurrentTime()|date('Y-m-d')) %}
```
{% endraw %}
{% endcode %}

For this example we don't have to define constraints. We retrieve the current date from the scope, calling `getCurrentTime`. We modify the date to set it to the first day of the month, then modify it again to set it to the second wednesday from that point in time. We then compare that date against the current date for a condition that matches only on the second wednesday of each month.
