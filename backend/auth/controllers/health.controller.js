const health = (req,res) => {
    res.send({'health': 'OK'})
}

module.exports = { health }