import { Web3Storage } from 'web3.storage';

const client = new Web3Storage({ token: process.env.WEB3_STORAGE_TOKEN });

export async function uploadToIPFS(file) {
  const cid = await client.put([new File([file.buffer], file.originalname)]);
  return cid;
}
