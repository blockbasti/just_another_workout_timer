exports.preVersionGeneration = preVersionGeneration, exports.preTagGeneration = preTagGeneration;
function preVersionGeneration(version: string): string {
    version = process.env.VERSION;
}

function preTagGeneration(tag: string): string {
    tag = 'v' + process.env.VERSION;
}
