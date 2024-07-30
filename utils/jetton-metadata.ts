import { sha256_sync } from 'ton-crypto'
import { Cell, Dictionary, beginCell } from 'ton-core'

export interface JettonContent {
    name: string
    description: string
    symbol: string
    image: string
}

function bufferToChunks(buff: Buffer, chunkSize: number) {
    let chunks: Buffer[] = []
    while (buff.byteLength > 0) {
        chunks.push(buff.subarray(0, chunkSize))
        buff = buff.subarray(chunkSize)
    }
    return chunks
}

export function makeSnakeCell(data: Buffer): Cell {
    const chunks = bufferToChunks(data, 127)

    if (chunks.length === 0) {
        return beginCell().endCell()
    }

    if (chunks.length === 1) {
        return beginCell().storeBuffer(chunks[0]).endCell()
    }

    let curCell = beginCell()

    for (let i = chunks.length - 1; i >= 0; i--) {
        const chunk = chunks[i]

        curCell.storeBuffer(chunk)

        if (i - 1 >= 0) {
            const nextCell = beginCell()
            nextCell.storeRef(curCell)
            curCell = nextCell
        }
    }

    return curCell.endCell()
}

export function buildJettonContent(data: JettonContent): Cell {
    let dict = Dictionary.empty(Dictionary.Keys.BigUint(256), Dictionary.Values.Cell())

    Object.entries(data).forEach(([key, value]) => {
        if (!!value) {
            dict.set(BigInt(`0x${sha256_sync(key).toString('hex')}`), makeSnakeCell(Buffer.from(value, 'utf8')))
        }
    })
    return beginCell().storeInt(0x00, 8).storeDict(dict).endCell()
}
