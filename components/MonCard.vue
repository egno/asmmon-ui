<template>
  <div :class="[className, attention]" :id="id" :style="{height:height,width:width}">
    <div class="card-title" :title="titles.title">
      {{title}}
    </div>
    <div class="card-content" v-if="displayValues" :title="titles.values">
      {{displayValues || '---'}}
    </div>
    <div class="card-subtitle" v-if="subtitle" :title="titles.subtitle">
      {{subtitle}}
    </div>
  </div>
</template>

<script>
export default {
  props: {
    className: {
      type: String,
      default: 'card'
    },
    id: {
      type: String,
      default: 'card'
    },
    width: {
      type: String,
      default: '47%'
    },
    height: {
      type: String,
      default: '27%'
    },
    attention: {
      type: String,
      default: ''
    },
    title: {
      type: String,
      default: ''
    },
    subtitle: {
      type: String,
      default: ''
    },
    titles: {
      default () {
        return {
          title: '',
          subtitle: '',
          values: ''
        }
      }
    },
    values: {
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
      if (!this.values) return '---'
      return (Array.isArray(this.values))
        ? (this.values[0] || '-') + ' / ' + (this.values[1] || '-')
        : this.values
    }
  }
}
</script>

<style>
.card {
  background: #222;
  flex-direction: column;
  flex-wrap: nowrap;
  justify-content: center;
  align-items: center;
  text-align: center;
}
.card-subtitle {
  color: #555;
  font-size: 0.8em;
}
.card-content {
  color: #0b0;
  margin: auto;
  font-size: 3em;
}
.alert > .card-content {
  color: #f00;
}
</style>
