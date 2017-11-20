<template>
<div :class="className" :id="id" :style="{height:height,width:width}"></div>
</template>

<script>
import echarts from 'echarts'
export default {
  props: {
    className: {
      type: String,
      default: 'chart'
    },
    id: {
      type: String,
      default: 'chart'
    },
    width: {
      type: String,
      default: '200px'
    },
    height: {
      type: String,
      default: '200px'
    },
    xAxisData: {
      default: []
    },
    series: {
      default: []
    },
    legend: {
      default: []
    },
    minLevel: {
      default: 0
    },
    lineColorHues: {
      default () {
        return [40, 180, 90, 0]
      }
    },
    title: {
      default: 'График сборки'
    }
  },
  data () {
    return {
      chart: null
    }
  },
  watch: {
    'series': 'refreshChart',
    'xAxisData': 'refreshChart',
    'minLevel': 'refreshChart',
    'title': 'refreshChart'
  },
  mounted () {
    this.initChart()
  },
  beforeDestroy () {
    if (!this.chart) {
      return
    }
    this.chart.dispose()
    this.chart = null
  },
  methods: {
    initChart () {
      this.chart = echarts.init(document.getElementById(this.id))
      this.chart.setOption({
        backgroundColor: '#000',
        title: {
          text: this.title,
          textStyle: {
            color: '#888'
          },
          x: 'center'
        },
        tooltip: {
          trigger: 'axis',
          axisPointer: {
            lineStyle: {
              color: '#555'
            }
          }
        },
        legend: {
          icon: 'rect',
          itemWidth: 14,
          itemHeight: 5,
          itemGap: 13,
          data: this.legend,
          bottom: '1%',
          textStyle: {
            fontSize: 12,
            color: '#999'
          },
          x: 'center'
        },
        grid: {
          left: '3%',
          right: '4%',
          bottom: '5%',
          containLabel: true
        },
        xAxis: [{
          type: 'category',
          boundaryGap: false,
          axisLine: {
            lineStyle: {
              color: '#57617B'
            }
          },
          data: this.xAxisData
        }],
        yAxis: [{
          type: 'value',
          name: 'Поз./час',
          axisTick: {
            show: false
          },
          axisLine: {
            lineStyle: {
              color: '#57617B'
            }
          },
          axisLabel: {
            margin: 10,
            textStyle: {
              fontSize: 12
            }
          },
          splitLine: {
            lineStyle: {
              color: '#57617B'
            }
          }
        }],
        series: this.series.map((x, i) => {
          return {
            name: this.legend[i],
            type: 'line',
            smooth: true,
            symbol: 'circle',
            symbolSize: 5,
            showSymbol: false,
            lineStyle: {
              normal: {
                width: 2
              }
            },
            areaStyle: {
              normal: {
                color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [{
                  offset: 0.1,
                  color: `hsla(${this.lineColorHues[i]}, 100%, 50%, 0.2)`
                }, {
                  offset: 0.5,
                  color: `hsla(${this.lineColorHues[i]}, 100%, 50%, 0)`
                }], false),
                shadowColor: 'rgba(0, 0, 0, 0.1)',
                shadowBlur: 10
              }
            },
            itemStyle: {
              normal: {
                color: `hsla(${this.lineColorHues[i]}, 100%, 50%, 0.8)`,
                borderColor: `hsla(${this.lineColorHues[i]}, 100%, 50%, 0.27)`,
                borderWidth: 12
              }
            },
            data: x
          }
        })
      })
    },
    refreshChart () {
      this.chart.setOption({
        title: {
          text: this.title
        },
        xAxis: [{
          data: this.xAxisData
        }],
        series: this.series.map((x, i) => {
          return {
            name: this.legend[i],
            data: this.series[i]
          }
        })
      })
    }
  }
}
</script>
