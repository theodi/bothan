---
layout: default
---

# Visualisations

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
