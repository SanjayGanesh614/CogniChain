import { uploadToIPFS } from '../../utils/ipfsClient.js';
import { listModel } from '../../utils/clarityClient.js';

export async function uploadModel(req, res) {
  try {
    const file = req.file;
    const { price, paymentToken } = req.body;

    if (!file) {
      return res.status(400).json({ error: 'File missing' });
    }

    // 1. Upload Model File to IPFS
    const cid = await uploadToIPFS(file);

    // 2. Prepare metadata JSON here (optional)...

    // 3. Call contract function to mint NFT & list model
    const tokenId = await listModel(Number(price), paymentToken || null);

    return res.json({ success: true, tokenId, ipfsCid: cid });
  } catch (error) {
    console.error('Upload error', error);
    return res.status(500).json({ error: error.message });
  }
}
