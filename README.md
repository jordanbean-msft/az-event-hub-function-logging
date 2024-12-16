# az-event-hub-function-logging

![architecture](./.img/architecture.drawio.svg)

## Disclaimer

**THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.**

## Prerequisites

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Azure subscription & resource group
- [Terraform](https://developer.hashicorp.com/terraform/install?product_intent=terraform#windows)
- [Azure Developer CLI](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd?tabs=winget-windows%2Cbrew-mac%2Cscript-linux&pivots=os-windows)
- `Owner` level permissions on the resource group you wish to apply the Terraform to (since it uses RBAC to set up access to Cosmos, OpenAI, Key Vault, etc)

## Deployment

## Deployment

1. Update the `infra/provider.conf.json` file with where you intend to store the Terraform state file.
1. Update the `infra/main.tfvars.json` file with specifics of your environment.

1. Run the following command to deploy the solution

    ```shell
    azd up
    ```


## Links
