exports.preVersionGeneration = preVersionGeneration, exports.preTagGeneration = preTagGeneration;
function preVersionGeneration(version) {
    version = process.env.VERSION;
}

function preTagGeneration(tag){
    tag = 'v' + process.env.VERSION;
}
