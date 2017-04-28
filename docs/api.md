---
layout: default
title: API
---

The API is the heart of Bothan, where you submit the data you want to **store** and **visualise**. There is also a read portion of the API that allows you to list metrics for a given time period.

## Software Libraries

There are two libraries that make interfacing with Bothan super easy:

* [Ruby](https://github.com/theodi/bothan.rb)
* [Node.js](https://github.com/theodi/bothan.js)

## Adding data

All POST requests require a username and password (sent via basic auth)

```bash
POST https://username:password@demo.bothan.io/metrics/{metric-name}
```

using a JSON content type, and with the following JSON in the body:

```json
{
  "time": "{iso8601-date-time}",
  "value": ...
}
```

cURL example:

```bash
curl -X POST -H "Content-Type: application/json" -d '{
  "time": "2016-04-12T10:00:00",
  "value": 500
}' "https://username:password@demo.bothan.io/metrics/simple-value"
```

`value` can be in any one of the following formats:

### Simple value

The simplest format that a `value` can take is a single number. For example:

```json
{
  "time": "{iso8601-date-time}",
  "value": 123
}
```

### Value with a target

A value can also be a JSON object with an `actual`, `annual_target` and an optional `ytd_target`. For example:

```json
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

```json
{
  "time": "{iso8601-date-time}",
  "value": {
    "actual": 1091000,
    "annual_target": 2862000
  }
}
```

### Multiple values

If you want to track multiple values for one metric (for example, diversity data), we can do that too:

```json
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

### Geographical data

Want to add geodata to visualise on a map? You got it! Simply POST your data with an iso8601 DateTime, with a GeoJSON `FeatureCollection` as the value. For example:

```json
{
  "time": "{iso8601-date-time}",
  "value": {
    "type:": "FeatureCollection",
    "features": [
      {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates":
            [-2.6156582783015017, 54.3497405310758]
          }
      },
      {
        "type": "Feature",
        "geometry": {
          "type": "Point",
           "coordinates":
           [-6.731370299641439, 55.856756177781186]
          }
      }
    ]
  }
}
```

Any type of `geometry` is supported. For more information, check out the [GeoJSON spec](http://geojson.org/).

## Adding metrics

If a {metric-name} is sent by a POST and does not already exist in the Bothan instance then a new metric will be created.

## Deleting metrics

There is currently no way to delete a metric within an instance of Bothan.

## Fetching data

```bash
GET https://demo.bothan.io/metrics[.json]
```

Fetches list of available metrics

```bash
GET https://demo.bothan.io/metrics/{metric_name}[.json]
```

Fetches latest value for specified metric

```bash
GET https://demo.bothan.io/metrics/{metric_name}/{time}
```

Fetch the most recent value of the metric at the specified time. `time` is an ISO8601 date/time.

```bash
GET https://demo.bothan.io/metrics/{metric_name}/{from}/{to}
```

Fetch all values of the metric between the specified times. `from` and `to` can be either:

 * An ISO8601 date/time
 * An ISO8601 duration
 * `*`, meaning unspecified



## Visualising data

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