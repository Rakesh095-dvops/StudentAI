//make sure to install these packages express nodemon ejs in your system
const express = require('express')
const app = express()
const port = 3000
app.set('view engine','ejs')

// go to the /hello route to view the rendered page
app.get('/hello', (req, res) => {
  res.render('index')
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})