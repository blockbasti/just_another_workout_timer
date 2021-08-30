export function preVersionGeneration(version: string): string {
    version = process.env.VERSION;
}

export function preTagGeneration(tag: string): string {
    tag = 'v' + process.env.VERSION
}