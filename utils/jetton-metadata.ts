import { sha256_sync } from 'ton-crypto'
import { Dictionary, beginCell, Cell } from '@ton/core'

export interface JettonContent {
    name: string
    description: string
    symbol: string
    image: string
}

export function buildJettonContent(data: JettonContent): Cell {
    let dict = Dictionary.empty(Dictionary.Keys.BigUint(256), Dictionary.Values.Cell())

    Object.entries(data).forEach(([key, value]) => {
        dict.set(BigInt(`0x${sha256_sync(key).toString('hex')}`), makeSnakeCell(Buffer.from(value, 'utf8')))
    })

    return beginCell().storeInt(0x00, 8).storeDict(dict).endCell()
}

export function makeSnakeCell(data: Buffer) {
    let chunks = bufferToChunks(data, Math.floor((1023 - 8) / 8))

    const b = chunks.reduceRight((curCell, chunk, index) => {
        if (index === 0) {
            curCell.storeInt(0x00, 8)
        }
        curCell.storeBuffer(chunk)
        if (index > 0) {
            const cell = curCell.endCell()
            return beginCell().storeRef(cell)
        } else {
            return curCell
        }
    }, beginCell())
    return b.endCell()
}

function bufferToChunks(buff: Buffer, chunkSize: number) {
    let chunks: Buffer[] = []
    while (buff.byteLength > 0) {
        chunks.push(buff.slice(0, chunkSize))
        buff = buff.slice(chunkSize)
    }
    return chunks
}
