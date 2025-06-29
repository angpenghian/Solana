# Solana Validator Setup Guide


# Keypair Generation
### Identity Keypair
- Required by the solana-validator executable to identify the validator and pay for voting fees\
`solana-keygen new -o validator-keypair.json`

### Vote Account Keypair
- Public key is used by delegators to delegate SOL to your vote account
- The private key has no use once the vote account is created (Do not throw away the private key as future Solana development might need it)\
`solana-keygen new -o vote-account-keypair.json`

### Withdrawer Keypair
- Used to withdraw funds from the vote account, can change identity key or withdrawer key
- Should not be stored on the machine running the validator\
- Should be kept in securely stored: hardware wallet, multisig or both\
`solana-keygen new -o authorized-withdrawer-keypair.json`

### Vanity Keypair
`solana-keygen grind --starts-with <brandname>:1`\
`solana-keygen grind --use-mnemonic --starts-with <brandname>:1`\
example generated penghianioj98gufd9483u

### Check Public Key
`solana-keygen pubkey <keypair-file>`

# Snapshot
### Catchup
- If a validator restarts from a snapshot, it must catchup to the chain\
- It is typical for a validator to be up to 1500 slots behind the tip of the chain after  downliading a snapshot
- Two commands for monitoring catchup:\
-- `solana catchup`\
-- `solana-validator monitor`

# Account notes
Unless there is balance in the wallet address, it will not EXIST ONCHAIN.\
You can check if the wallet exists by running
- Check Testnet account\
`solana -ut account ./validator-keypair.json`
- Check Mainnet account\
`solana -um account ./validator-keypair.json`

You can check if the wallet balance is sufficient to create the vote account by running
- Check Testnet account balance\
`solana -ut balance ./validator-keypair.json`
- Check Mainnet account balance\
`solana -um balance ./validator-keypair.json`

# Vote Account Creation
Now that you have the keypairs, you can create the vote account.\
```bash
solana create-vote-account -ut \
    # Keypair used to pay the fees for the vote account creation, can be another keypair with sufficient balance
    --fee-payer ./validator-keypair.json \

    # <ACCOUNT_KEYPAIR> Vote account keypair to create
    ./vote-account-keypair.json \

    # <IDENTITY_KEYPAIR> Keypair of validator that will vote with this account
    ./validator-keypair.json \

    #  <WITHDRAWER_PUBKEY> Authorized withdrawer. Address is one of:
                             # * a base58-encoded public key
                             # * a path to a keypair file
                             # * a hyphen; signals a JSON-encoded keypair on stdin
                             # * the 'ASK' keyword; to recover a keypair via its seed phrase
                             # * a hardware wallet keypair URL (i.e. usb://ledger)
    ./authorized-withdrawer-keypair.json
```


# Airdops / Faucet
### Airdrop
You can airdrop SOL to the validator account on TESTNET via\
`solana -ut airdrop 1 ./validator-keypair.json`
### Faucet
You can also use the Solana Faucet at\
https://faucet.solana.com/

To get your wallet address, run\
`solana-keygen pubkey validator-keypair.json`

# Startup Script
Show summary information of the current validators on network\
`solana validators -ut`

Show the contact/IP/RPC ports information of the validators on network\
`solana gossip -ut`

### Script
```bash
#!/bin/bash
exec agave-validator \
    # Validator identity keypair
    --identity /home/sol/validator-keypair.json \

    # Validator vote account public key. If unspecified, voting will be disabled.
    # The authorized voter for the account must either be the --identity keypair or set by the --authorized-voter argument
    --vote-account /home/sol/vote-account-keypair.json \

    # A snapshot hash must be published in gossip by this validator to be accepted. May be specified multiple times. 
    # If unspecified any snapshot hash will be accepted
    --known-validator 5D1fNXzvv5NjV1ysLjirC4WY92RNsVH18vjmcszZd8on \
    --known-validator 7XSY3MrYnK8vq693Rju17bbPkCN3Z7KvvfvJx4kdrsSY \
    --known-validator Ft5fbkqNa76vnsjYNwjDZUXoTWpP7VYm3mtsaQckQADN \
    --known-validator 9QxCLckBiJc783jnMvXZubK4wH86Eqqvashtrwvcsgkv \

    # Use the RPC service of known validators only
    --only-known-rpc \

    # Redirect logging to the specified file, '-' for standard error. Sending the SIGUSR1 signal to the validator
    # process will cause it to re-open the log file
    --log /home/sol/agave-validator.log \

    # Use DIR as ledger location [default: ledger]
    --ledger /mnt/ledger \

    # Comma separated persistent accounts location. May be specified multiple times. [default: <LEDGER>/accounts]
    --accounts /mnt/accounts \

    # Enable JSON RPC on this port, and the next port for the RPC websocket
    --rpc-port 8899 \

    # Range to use for dynamically assigned ports [default: 8000-10000]
    --dynamic-port-range 8000-8020 \

    # Rendezvous with the cluster at this gossip entrypoint
    --entrypoint entrypoint.testnet.solana.com:8001 \
    --entrypoint entrypoint2.testnet.solana.com:8001 \
    --entrypoint entrypoint3.testnet.solana.com:8001 \

    # Require the genesis have this hash
    --expected-genesis-hash 4uhcVJyU9pJkvQyS88uRDiswHXSCkY3zQawwpjk2NsNY \

    # Mode to recovery the ledger db write ahead log. [possible values: tolerate_corrupted_tail_records,
    # absolute_consistency, point_in_time, skip_any_corrupted_record]
    --wal-recovery-mode skip_any_corrupted_record \

    # Keep this amount of shreds in root slots.
    --limit-ledger-size
```

# Personal notes
### lazy to type
docker system prune -a\
docker-compose up -d --build\
docker exec -it solana-validator /bin/bash\
solana --version 