<template>
  <div :class="[className, state]" :id="id" :style="{height:height,width:width}" :title="note">
    <div class="tile-title">
      {{title}}
    </div>
    <div class="tile-content">
      {{value || "&nbsp;" }}
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
    note: {
      type: String,
      default: ''
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
  padding: 0.1em;
  margin: 1px;
  border: 4px solid #282828;
}
.tile-title {
  color: #999;
}
.tile-content {
  margin: auto;
  font-weight: bold;
  color: #777;
}
.MinAlert {
  border-color: #600;
}
.MinWarning {
  border-color: #770;
}
.MaxAlert {
  border-color: #a00;
}
.MaxWarning {
  border-color: #770;
}
.Normal {
  border-color: #040;
}
</style>
