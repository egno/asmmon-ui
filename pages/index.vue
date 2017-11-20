<template>
  <section class="main">
    <div class="header">
      <h1>
        Текущая скорость сборки (позиций в час) по филиалам
      </h1>
      <p>
        Нажмите на филиал чтобы загрузить детализацию
      </p>
    </div>
    <div class="tiles">
      <nuxt-link v-for="server in servers"
      :to="'/mon/' + server.code"
      :key="server.code">
        <mon-mini-info
        :title="server.caption"
        :server="server.code"
        :url="url"
        ></mon-mini-info>
      </nuxt-link>
    </div>
    <notes></notes>
  </section>
</template>

<script>
import MonMiniInfo from '~/components/MonMiniInfo.vue'
import Notes from '~/components/Notes.vue'
const axios = require('axios')

export default {
  data () {
    return {
      queryError: '',
      servers: [
      ],
      url: '/api/v1/'
    }
  },
  components: {
    MonMiniInfo,
    Notes
  },
  methods: {
    getServers () {
      axios.get(this.url + '')
        .then((res) => {
          this.servers = res.data.sort((a, b) => (a.caption > b.caption) ? 1 : -1)
          this.queryError = ''
        })
        .catch((err) => {
          this.queryError = 'Нет ответа от сервера'
          console.log(err)
        })
    }
  },
  mounted () {
    this.getServers()
  }
}
</script>

<style>
body {
  background: #000;
}
.main {
  background: #000;
  color: #aaa;
  display: flex;
  flex-direction: column;
  justify-content: space-around;
  align-content: flex-start;
  align-items: center;
  text-align: center;
  font-family: "Quicksand", "Source Sans Pro", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif; /* 1 */
}
.header {
  margin: 2em;
}
.tiles {
  margin: 2em;
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  justify-content: space-around;
  align-content: flex-start;
  font-weight: bold;
  color: #35495e;
  letter-spacing: 1px;
}

.mon-tile {
  display: flex;
  justify-content: center;
  align-items: center;
  margin: 0.5em;
  background: #333;
  min-width: 13em;
  height: 2em;
}

a {
  color: #999;
  text-decoration: none;
}
</style>
