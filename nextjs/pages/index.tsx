import { useState, useEffect } from 'react'
import type { NextPage } from 'next'
import { useAccount, useWriteContract } from 'wagmi'

import { ConnectButton } from '@rainbow-me/rainbowkit'
import { parseAbi, encodeFunctionData } from 'viem'
import Button from '@mui/material/Button'
import Grid from '@mui/material/Grid'
// import { useScaffoldReadContract, useScaffoldWriteContract } from "~~/hooks/scaffold-eth";

import {
  getProof,
  verifyProofFrontend,
  sendPCDToServer,
  generateWitness
} from '../lib/pcd'
import { CircularProgress } from '@mui/material'

const abi = parseAbi([
  'function grantUbi(address user, ProofArgs calldata proof)',
  'struct ProofArgs { uint256[2] _pA; uint256[2][2] _pB; uint256[2] _pC; uint256[38] _pubSignals; }'
])

const Home: NextPage = () => {
  const { data: hash, isPending, writeContract } = useWriteContract()

  const [connecting, setConnecting] = useState(false)
  const [verified, setVerified] = useState(false)
  const [verifiedOnChain, setVerifiedOnChain] = useState(false)
  const { address: connectedAddress } = useAccount()

  // mintItem verifies the proof on-chain and mints an NFT
  // const { writeContractAsync: mintNFT, isPending: isMintingNFT } =
  //   useScaffoldWriteContract('YourCollectible')

  // const { data: yourBalance } = useScaffoldReadContract({
  //   contractName: 'YourCollectible',
  //   functionName: 'balanceOf',
  //   args: [connectedAddress]
  // })

  const verifyOnChain = async () => {
    try {
      // const data = encodeFunctionData({
      //   abi,
      //   functionName: 'grantUbi',
      //   args: [connectedAddress as `0x${string}`, generateWitness(JSON.parse(pcd))]
      // })

      // await mintNFT({
      //   functionName: 'mintItem',
      //   // @ts-ignore TODO: fix the type later with readonly fixed length bigInt arrays
      //   args: [pcd ? generateWitness(JSON.parse(pcd)) : undefined]
      // })
    
      // writeContract({
      //       address: '0xFBA3912Ca04dd458c843e2EE08967fC04f3579c2',
      //       abi,
      //       functionName: 'authenticate',
      //       args: [connectedAddress as `0x${string}`]
      //     })
      //   }
    } catch (e) {
      console.error(`Error: ${e}`)
      return
    }
    setVerifiedOnChain(true)
  }

  useEffect(() => {
    const init = async () => {
      if (connectedAddress && !verified) {
        setConnecting(true)
        const _pcd = await getProof(connectedAddress)
        if (_pcd) {
          const proof = await verifyProofFrontend(_pcd, connectedAddress)
          if (proof) {
            const _verified = await sendPCDToServer(_pcd, connectedAddress)
            if (_verified) {
              setVerified(true)
              setConnecting(false)
            }
          }
        }
      }
    }
    init()
  }, [connectedAddress, verified])

  return (
    <Grid
      container
      justifyContent='center'
      alignItems='center'
      flexDirection='column'
    >
      <h1>Zero Knowledge UBI {'<'}3</h1>
      <ConnectButton />
      {connectedAddress != null && (
        <Button
          disabled={isPending || connecting || !verified || verifiedOnChain}
          style={{ marginTop: 20, borderRadius: 10, padding: 10 }}
          onClick={verifyOnChain}
        >
          {connecting ? (
            <>
              Connecting...
              <CircularProgress size={20} sx={{ ml: 2 }} />
            </>
          ) : (
            'Give me my UBI 🌈❤️'
          )}
        </Button>
      )}
      {/* {yourBalance && yourBalance >= 1n
                  ? '🎉 🍾 proof verified in contract!!! 🥂 🎊'
                  : ''} */}
    </Grid>
  )
}

export default Home
