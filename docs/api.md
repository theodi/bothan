---
layout: default
title: API
---

The API is the heart of Bothan, where you submit the data you want to store and visualise. There is also a read portion of the API that allows you to list metrics for a given time period.

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
