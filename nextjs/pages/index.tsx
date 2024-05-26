import { useState, useEffect } from 'react'
import type { NextPage } from 'next'
import { useAccount, useWriteContract } from 'wagmi'
import { readContract } from '@wagmi/core'
import { formatEther } from 'viem'
import { ConnectButton } from '@rainbow-me/rainbowkit'
import Button from '@mui/material/Button'
import Grid from '@mui/material/Grid'

import abi from '../assets/abi.json'

import {
  getProof,
  verifyProofFrontend,
  sendPCDToServer,
  generateWitness
} from '../lib/pcd'
import { CircularProgress } from '@mui/material'
import { http, createConfig } from '@wagmi/core'
import { mainnet, sepolia } from '@wagmi/core/chains'

export const _config = createConfig({
  chains: [mainnet, sepolia],
  transports: {
    [mainnet.id]: http(),
    [sepolia.id]: http()
  }
})

const CONTRACT_ADDRESS = '0xa214801904db795be028b4c0f7e33b06976b0bbb'

const Home: NextPage = () => {
  const { data: hash, isPending, writeContract } = useWriteContract()

  const [connecting, setConnecting] = useState(false)
  const [verified, setVerified] = useState(false)
  const [pcd, setPcd] = useState('')
  const [verifiedOnChain, setVerifiedOnChain] = useState(false)
  const { address: connectedAddress } = useAccount()
  const [balance, setBalance] = useState(0)

  useEffect(() => {
    const interval = setInterval(async () => {
      const result = connectedAddress ? readContract(_config, {
        address: CONTRACT_ADDRESS,
        abi,
        functionName: 'balanceOf',
        args: [connectedAddress]
      }) : 0;
      setBalance(result as number)
    }, 1000)
    return () => clearInterval(interval)
  }, [connectedAddress])

  const verifyOnChain = async () => {
    try {
      writeContract({
        address: CONTRACT_ADDRESS,
        abi,
        functionName: 'grantUbi',
        args: [
          connectedAddress as `0x${string}`,
          generateWitness(JSON.parse(pcd))
        ]
      })
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
          setPcd(_pcd)
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
      {balance && BigInt(balance) >= BigInt(1)
        ? `🎉 🍾 proof verified in contract!!! 🥂 🎊 Balance: ${parseFloat(
            formatEther(BigInt(balance))
          )} zkUbi`
        : ''}
    </Grid>
  )
}

export default Home
