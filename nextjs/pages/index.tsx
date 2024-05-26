import { useState, useEffect } from 'react'
import type { NextPage } from 'next'
import { useAccount, useWriteContract } from 'wagmi'
import { readContract } from '@wagmi/core'
import { formatEther } from 'viem'
import { ConnectButton } from '@rainbow-me/rainbowkit'
import Button from '@mui/material/Button'
import Grid from '@mui/material/Grid'
import Box from '@mui/material/Box'

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

const CONTRACT_ADDRESS = '0xB7E9285896A7012f8fB9E4F257E2F0584E7e175A'

const Home: NextPage = () => {
  const { data: hash, isPending, writeContractAsync } = useWriteContract()

  const [connecting, setConnecting] = useState(false)
  const [verified, setVerified] = useState(false)
  const [pcd, setPcd] = useState('')
  const [verifiedOnChain, setVerifiedOnChain] = useState(false)
  const { address: connectedAddress } = useAccount()
  const [balance, setBalance] = useState(0)

  useEffect(() => {
    const interval = setInterval(async () => {
      if (!connectedAddress) return
      const result = await readContract(_config, {
        address: CONTRACT_ADDRESS,
        abi,
        functionName: 'balanceOf',
        args: [connectedAddress]
      });
      setBalance(result as number)
    }, 1000)
    return () => clearInterval(interval)
  }, [connectedAddress])

  const verifyOnChain = async () => {
    try {
      const res = await writeContractAsync({
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

  return (
    <Grid
      container
      justifyContent='center'
      alignItems='center'
      flexDirection='column'
    >
      <Grid
        container
        justifyContent='space-between'
        sx={{ px: 5 }}
        alignItems='flex-start'
      >
        <h1>Zero Knowledge UBI {'<'}3</h1>
        <Box sx={{ mt: 2 }}>
          <ConnectButton showBalance={false} />
        </Box>
      </Grid>
      {connectedAddress && (
        <>
          {!verified && BigInt(balance) == BigInt(0) ? (
            <Button
              variant='contained'
              onClick={() => {
                const connect = async () => {
                  if (connectedAddress && !verified) {
                    setConnecting(true)
                    const _pcd = await getProof(connectedAddress)
                    if (_pcd) {
                      const proof = await verifyProofFrontend(
                        _pcd,
                        connectedAddress
                      )
                      setPcd(_pcd)
                      if (proof) {
                        const _verified = await sendPCDToServer(
                          _pcd,
                          connectedAddress
                        )
                        if (_verified) {
                          setVerified(true)
                          setConnecting(false)
                        }
                      }
                    }
                  }
                }
                connect()
              }}
            >
              {connectedAddress
                ? 'Login with Zupass'
                : 'Start by Connecting wallet'}
            </Button>
          ) : (
            <></>
          )}
          {verified && !verifiedOnChain && (
            <Button
              variant='contained'
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
          <Box sx={{ fontSize: '40px' }}>
            <h2>{formatEther(BigInt(balance))} zkUbi</h2>
          </Box>
          {balance && BigInt(balance) >= BigInt(1)
            ? '🎉 🍾 proof verified in contract!!! 🥂 🎊'
            : ''}
        </>
      )}
    </Grid>
  )
}

export default Home
