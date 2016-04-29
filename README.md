[![Build Status](http://img.shields.io/travis/theodi/bothan.svg?style=flat-square)](https://travis-ci.org/theodi/bothan)
[![Dependency Status](http://img.shields.io/gemnasium/theodi/bothan.svg?style=flat-square)](https://gemnasium.com/theodi/bothan)
[![Coverage Status](http://img.shields.io/coveralls/theodi/bothan.svg?style=flat-square)](https://coveralls.io/r/theodi/bothan)
[![Code Climate](http://img.shields.io/codeclimate/github/theodi/bothan.svg?style=flat-square)](https://codeclimate.com/github/theodi/bothan)
[![License](http://img.shields.io/:license-mit-blue.svg?style=flat-square)](http://theodi.mit-license.org)

# Bothan

## Brings you information

A simple wrapper around MongoDB to allow storage of time series metrics.

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

## Content negotiation

The API will respond to the following _Accept_ values with appropriate content:

`application/json`

Content will be returned as a JSON object

`text/html`

Content will be returned as HTML (see below for more)

## API

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

### Adding data

```
POST https://demo.bothan.io/metrics/{metric-name}
```

using a JSON content type, and with the following JSON in the body:

```
{
  "time": "{iso8601-date-time}",
  "value": ...
}
```

`value` is any valid JSON structure or number.

## HTML

While this is primarily a JSON API, some of our endpoints will also serve HTML. Primarily:

```
GET https://demo.bothan.io/metrics/{metric_name}/{from}/{to}
```

(or `GET https://demo.bothan.io/metrics/{metric_name}` which will redirect to a default time-range of the last 30 days)

### query-string options

The rendering can be manipulated by the following query-string options:

#### layout

One of:

  * `rich`, with a nav-bar and other controls, or
  * `bare`, a minimal layout designed for inclusion elsewhere as an iframe

Default: `rich`

#### type

One of:

  * `chart`, which renders a [Plotly](https://plot.ly/javascript/) line chart of the data, as best it can (it attempts to extract reasonable y-axis-values from the metric, but some metrics simply do not make sense in this form. Caveat Graphor)
  * `number`, which displays the latest value from the metric (if it can find such a thing)
  * `pie`, which renders a [Plotly](https://plot.ly/javascript/) pie chart of the data, as best it can
  * `target`, which renders a meter style chart with an actual value, an annual target value and a year to date target value. For this to work, the data should be in the following format:

  ```
  {
    "actual": value,
    "annual_target": value,
    "ytd_target": value,
  }
  ```
  * `tasklist`, which renders a list of tasks and their progress. This is highly specialised to ODI, and may not be relevant to anyone else's needs, but if you want to use this visualisation, the data should be in this format:
  ```
  [
    {
      "title": "Task name",
      "due": "Due date in ISO8601 format",
      "progress": A float value between 0 and 1,
    },
    ...
  ]
  ```

Default: `chart`

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

### Setting metadata

You can also set a limited amount of metadata via the API:

```
POST https://demo.bothan.io/metrics/{metric-name}/metadata
```

Currently accepted attributes are:

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
