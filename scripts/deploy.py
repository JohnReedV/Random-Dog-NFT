from brownie import accounts, network, config, CoolDogs

LOCAL_BLOCKCHAIN_ENVIROMENTS = ["hardhat",
                                "development", "ganache", "mainnet-fork"]
OPENSEA_URL = "https://testnets.opensea.io/assets/{}/{}"


def get_account(index=None, id=None):
    if index:
        return accounts[index]
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIROMENTS:
        return accounts[0]
    if id:
        return accounts.load[0]
    return accounts.add(config["wallets"]["from_key"])


def main():
    account = get_account()
    run = CoolDogs.deploy({"from": account})
    tx = run.createCollectable({"from": account})
    tx.wait(1)
    print(
        f"View it here {OPENSEA_URL.format(run.address, run.tokenCounter() - 1)}")
