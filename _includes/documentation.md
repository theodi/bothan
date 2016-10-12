## Documentation

### Adding data

All POST requests require a username and password (sent via basic auth)

```
POST https://username:password@demo.bothan.io/metrics/{metric-name}
```

using a JSON content type, and with the following JSON in the body:

```
{
  "time": "{iso8601-date-time}",
  "value": ...
}
```

cURL example:

```
curl -X POST -H "Content-Type: application/json" -d '{
  "time": "2016-04-12T10:00:00",
  "value": 500
}' "https://username:password@demo.bothan.io/metrics/simple-value"
```

`value` can be in any one of the following formats:

#### Simple value

The simplest format that a `value` can take is a single number. For example:

```
{
  "time": "{iso8601-date-time}",
  "value": 123
}
```

#### Value with a target

A value can also be a JSON object with an `actual`, `annual_target` and an optional `ytd_target`. For example:

```
{
  "time": "{iso8601-date-time}",
  "value": {
    "actual": 1091000,
    "annual_target": 2862000,
    "ytd_target": 1368000
  }
}
```

Or:

```
{
  "time": "{iso8601-date-time}",
  "value": {
    "actual": 1091000,
    "annual_target": 2862000
  }
}
```

#### Multiple values

If you want to track multiple values for one metric (for example, diversity data), we can do that too:

```
{
  "time": "{iso8601-date-time}",
  "value": {
    "total": {
      "value1": 123,
      "value2": 23213,
      "value4": 1235
    }
  }
}
```
### Adding metrics

If a {metric-name} is sent by a POST and does not already exist in the Bothan instance then a new metric will be created.

### Deleting metrics

There is currently no way to delete a metric within an instance of Bothan.

### Fetching data

```
GET https://demo.bothan.io/metrics[.json]
```

Fetches list of available metrics

```
GET https://demo.bothan.io/metrics/{metric_name}[.json]
```

Fetches latest value for specified metric

```
GET https://demo.bothan.io/metrics/{metric_name}/{time}
```

Fetch the most recent value of the metric at the specified time. `time` is an ISO8601 date/time.

```
GET https://demo.bothan.io/metrics/{metric_name}/{from}/{to}
```

Fetch all values of the metric between the specified times. `from` and `to` can be either:

 * An ISO8601 date/time
 * An ISO8601 duration
 * `*`, meaning unspecified

### HTML

While this is primarily a JSON API, some of our endpoints will also serve HTML. Primarily:

```
GET https://demo.bothan.io/metrics/{metric_name}/{from}/{to}
```

(or `GET https://demo.bothan.io/metrics/{metric_name}` which will redirect to a default time-range of the last 30 days)

#### query-string options

The rendering can be manipulated by the following query-string options:

#### layout

One of:

  * `rich`, with a nav-bar and other controls, or
  * `bare`, a minimal layout designed for inclusion elsewhere as an iframe

Default: `rich`

#### type

One of:

  * `chart`, which renders a [Plotly](https://plot.ly/javascript/) line chart of the data: <br>
  <iframe src="http://demo.bothan.io/metrics/simple-metric?layout=bare&amp;boxcolour=2254f4&amp;textcolour=ffffff&amp;type=" width="100%" height="350px" frameborder="0" scrolling="no"></iframe>
  * `number`, which displays the latest value from the metric: <br>
  <iframe src="http://demo.bothan.io/metrics/simple-metric?layout=bare&amp;boxcolour=0dbc37&amp;textcolour=ffffff&amp;type=number" width="100%" height="350px" frameborder="0" scrolling="no"></iframe>
  * `pie`, which renders a [Plotly](https://plot.ly/javascript/) pie chart of the data, as best it can. This is only supported by the [multiple values](#multiple-values) metric type: <br>
  <iframe src="http://demo.bothan.io/metrics/metric-with-multiple-values?layout=bare&amp;boxcolour=ef3aab&amp;textcolour=ffffff&amp;type=pie" width="100%" height="350px" frameborder="0" scrolling="no"></iframe>
  * `target`, which renders a meter style chart with an actual value, an annual target value and a year to date target value. This is only supported by the [value with target](#value-with-target) metric type:<br>
  <iframe src="http://demo.bothan.io/metrics/metric-with-target?layout=bare&amp;boxcolour=ff6700&amp;textcolour=ffffff&amp;type=target" width="100%" height="350px" frameborder="0" scrolling="no"></iframe>

Default: By default, Bothan will attempt to work out the best visualisation for your metric

#### boxcolour

Background colour for the chart or number, in hex. Note that you should _not_ pass the leading _#_. Also note the English spelling

Default: `ddd`

#### textcolour

Text colour (and line colour for the chart), in hex. Note that you should _not_ pass the leading _#_. Also note the English spelling

Default: `222`

#### autorefresh

`meta-refresh` interval for the page

Default: `none`

Example: https://demo.bothan.io/metrics/github-open-issue-count?boxcolour=fa8100&textcolour=00ffff&layout=bare

## Setting metadata

You can also set a limited amount of metadata via the API and front-end:

```
POST https://demo.bothan.io/metrics/{metric-name}/metadata
```

Currently accepted API attributes are:

* type: One of `chart`, `tasklist`, `target` or `pie`<br><br>By default, the app will attempt to guess a sensible visualisation type for your metric. If you'd rather override this, you can set a default type

* name:
`name` A JSON object in the form:<br>
```JSON
{
    "language-code": "Title goes here"
}
```
<br>
Where `language-code` is the ISO language code of your title. You can specify as many or as few languages as you like.
<br><br >If this is not specified, the app will attempt to titleize your metric name (so `my-cool-metric` becomes `My Cool Metric`)

* description: A JSON object in the same format as `title`.<br><br>A description of what your metric shows - This will be revealed to the user when they hover over the title

#### Sample request

```JSON
{
  "type": "chart",
  "name": {
    "en": "My cool chart",
    "fr": "Mon tableau fraîche"
  },
  "description": {
    "en": "A chart showing some great data",
    "fr": "Un tableau montrant un grand données"
  }
}

```
A description can be set for the metric by logging into the Bothan instance on Heroku, selecting the metric and taking the option to 'Edit Metadata'.

### Dashboards

Once you've got some metrics, you can then get on with the serious business of building dashboards. Once logged in on your Bothan instance, you click on 'Create Dashboard' and build a dashboard with your metrics.

[Check out an example dashboard](http://demo.bothan.io/dashboards/bothan)
