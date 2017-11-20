<template>
  <div :class="[className, state]" :id="id" :style="{height:height,width:width}">
    <div class="tile-title">
      {{title}}
    </div>
    <div class="tile-content">
      {{value}}
    </div>
  </div>
</template>

<script>
export default {
  props: {
    className: {
      type: String,
      default: 'tile'
    },
    id: {
      type: String,
      default: 'tile'
    },
    width: {
      type: String,
      default: '4em'
    },
    height: {
      type: String,
      default: 'auto'
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
        return null
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
    }
  }
}
</script>

<style>
.tile {
  background: #222;
  flex-direction: column;
  align-items: center;
  text-align: center;
  padding: 0.3em;
  border: 1px solid gray;
}
.tile-content {
  margin: auto;
  font-weight: bold;
  color: #999;
}
.MinAlert {
  background: #a00;
}
.MinWarning {
  background: #770;
}
.MaxAlert {
  background: #a00;
}
.MaxWarning {
  background: #770;
}
</style>
