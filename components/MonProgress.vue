<template>
  <div>
    <div :class="[className, state]" :id="id" :style="{height:height,width:width}" title="Собрано позиций">
      <div class="bar" :style="'width: ' + percent"></div>
      <span class="text">
        {{title}}
      </span>
    </div>
  </div>
</template>
<script>
export default {
  props: {
    className: {
      type: String,
      default: 'progress-bar'
    },
    id: {
      type: String,
      default: 'progress-bar'
    },
    width: {
      type: String,
      default: '200px'
    },
    height: {
      type: String,
      default: '200px'
    },
    state: {
      type: String,
      default: ''
    },
    title: {
      type: String,
      default: ''
    },
    value: {
      default () {
        return 0
      }
    }
  },
  data () {
    return {
      status: true
    }
  },
  computed: {
    displayValues () {
      return (Array.isArray(this.values))
        ? this.values[0] + ' / ' + this.values[1]
        : this.values
    },
    percent () {
      return (this.value || 0) * 100 + '%'
    }
  }
}
</script>

<style>
.progress-bar {
  background: #222;
  margin: auto;
  position: relative;
  text-align: center;
}
.progress-bar > .bar {
  position: absolute;
  background-color: #040;
  height: 100%;
}
.progress-bar > .text {
  position: absolute;
  left: 45%
}
.attention > .bar{
  background-color: #800;
}
</style>
