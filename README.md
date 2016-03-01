[![Build Status](http://img.shields.io/travis/theodi/metrics-api.svg?style=flat-square)](https://travis-ci.org/theodi/metrics-api)
[![Dependency Status](http://img.shields.io/gemnasium/theodi/metrics-api.svg?style=flat-square)](https://gemnasium.com/theodi/metrics-api)
[![Coverage Status](http://img.shields.io/coveralls/theodi/metrics-api.svg?style=flat-square)](https://coveralls.io/r/theodi/metrics-api)
[![Code Climate](http://img.shields.io/codeclimate/github/theodi/metrics-api.svg?style=flat-square)](https://codeclimate.com/github/theodi/metrics-api)
[![License](http://img.shields.io/:license-mit-blue.svg?style=flat-square)](http://theodi.mit-license.org)

# ODI Metrics API

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
GET https://metrics.theodi.org/metrics[.json]
```

Fetches list of available metrics

```
GET https://metrics.theodi.org/metrics/{metric_name}[.json]
```

Fetches latest value for specified metric

```
GET https://metrics.theodi.org/metrics/{metric_name}/{time}
```

Fetch the most recent value of the metric at the specified time. `time` is an ISO8601 date/time.

```
GET https://metrics.theodi.org/metrics/{metric_name}/{from}/{to}
```

Fetch all values of the metric between the specified times. `from` and `to` can be either:

 * An ISO8601 date/time
 * An ISO8601 duration
 * `*`, meaning unspecified

### Adding data

```
POST https://metrics.theodi.org/metrics/{metric-name}
```

using a JSON content type, and with the following JSON in the body:

```
{
  "name": "{metric-name}",
  "time": "{iso8601-date-time}",
  "value": ...
}
```

`value` is any valid JSON structure or number.

## HTML

While this is primarily a JSON API, some of our endpoints will also serve HTML. Primarily:

```
GET https://metrics.theodi.org/metrics/{metric_name}/{from}/{to}
```

(or `GET https://metrics.theodi.org/metrics/{metric_name}` which will redirect to a default time-range of the last 30 days)

### query-string options

The rendering can be manipulated by the following query-string options:

#### layout

* One of: `rich`, with a nav-bar and other controls, or `bare`, a minimal layout designed for inclusion elsewhere as an iframe
* Default: `rich`

#### type

* One of: `chart`, which renders a [Plotly](https://plot.ly/javascript/) chart of the data, as best it can (it attempts to extract reasonable y-axis-values from the metric, but some metrics simply do not make sense in this form. Caveat Graphor); or `number`, which displays the latest value from the metric (if it can find such a thing)
* Default: `chart`

#### boxcolour

* Background colour for the chart or number, in hex. Note that you should _not_ pass the leading _#_. Also note the English spelling
* Default: ddd

#### textcolour

* Text colour (and line colour for the chart), in hex. Note that you should _not_ pass the leading _#_. Also note the English spelling
* Default: 222

#### autorefresh

* `meta-refresh` interval for the page
* Default: none

Example: http://metrics.theodi.org/metrics/github-open-issue-count?boxcolour=fa8100&textcolour=00ffff&layout=bare
