/**
 * QEK IPFS Connect
 * ----------------
 * Provides:
 *   1. Local embedded Helia node (optional)
 *   2. Remote IPFS HTTP API connection
 *   3. Automatic selection based on config
 */

import { createHelia, Helia } from "helia";
import { fs as heliaFs } from "@helia/fs";
import { create as createHttpClient, IPFSHTTPClient } from "kubo-rpc-client";
import { getQekConfig } from "./qek_config_core";

export type QekIPFSMode = "local" | "remote";

export interface QekIPFS {
  mode: QekIPFSMode;
  helia?: Helia;
  fs?: ReturnType<typeof heliaFs>;
  http?: IPFSHTTPClient;
}

/** Singleton cache */
let instance: QekIPFS | null = null;

export async function connectIPFS(): Promise<QekIPFS> {
  if (instance) return instance;

  const config = getQekConfig();
  const useRemote = !!config.secrets?.ipfsApiUrl;

  if (useRemote) {
    // ------------ REMOTE NODE (HTTP API) -----------------
    const url = config.secrets!.ipfsApiUrl;
    const token = config.secrets!.ipfsApiToken;

    const client = createHttpClient({
      url,
      headers: token ? { Authorization: `Bearer ${token}` } : undefined,
    });

    instance = {
      mode: "remote",
      http: client,
    };

    return instance;
  }

  // ------------ LOCAL HELIA NODE -----------------
  const helia = await createHelia();
  const fs = heliaFs(helia);

  instance = {
    mode: "local",
    helia,
    fs,
  };

  return instance;
}

export default connectIPFS;
