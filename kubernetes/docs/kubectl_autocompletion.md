Kubernetes `kubectl` command autocomplete might not work if the shell completion is not set up. Follow these steps to enable it:  

---

### **Enable kubectl Autocompletion (For Bash & Zsh)**
#### **1. Check if `bash-completion` is installed**
```bash
dpkg -l | grep bash-completion
```
If not installed, install it:
```bash
sudo apt install bash-completion -y
```

#### **2. Enable kubectl completion (For Bash)**
```bash
echo 'source <(kubectl completion bash)' >> ~/.bashrc
source ~/.bashrc
```

#### **3. Enable kubectl completion (For Zsh)**
```bash
echo 'autoload -U compinit; compinit' >> ~/.zshrc
echo 'source <(kubectl completion zsh)' >> ~/.zshrc
source ~/.zshrc
```

#### **4. Verify Autocompletion**
Now, try typing:
```bash
kubectl g[Tab]
```
It should suggest `get`, `get pods`, etc.

Let me know if you need further help! 🚀