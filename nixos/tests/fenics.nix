import ./make-test-python.nix ({ pkgs, ... }:

let inherit (import ./ssh-keys.nix pkgs)
  snakeOilPrivateKey snakeOilPublicKey;
  ssh-config = builtins.toFile "ssh.conf" ''
    UserKnownHostsFile=/dev/null
    StrictHostKeyChecking=no
  '';
  fenicsScript = pkgs.writeScript "poisson.py" ''
    #!/usr/bin/env python
    from dolfin import *

    mesh = UnitSquareMesh(MPI.comm_world, 20, 20)

    V = FunctionSpace(mesh, "Lagrange", 1)

    def boundary(x):
        return x[0] < DOLFIN_EPS or x[0] > 1.0 - DOLFIN_EPS

    u0 = Constant(0.0)
    bc = DirichletBC(V, u0, boundary)

    u = TrialFunction(V)
    v = TestFunction(V)
    f = Expression("10*exp(-(pow(x[0] - 0.5, 2) + pow(x[1] - 0.5, 2)) / 0.02)", degree=2)
    g = Expression("sin(5*x[0])", degree=2)
    a = inner(grad(u), grad(v))*dx
    L = f*v*dx + g*v*ds

    u = Function(V)
    solve(a == L, u, bc)
    print(u)
  '';
in
{
  name = "fenics";
  meta = {
    maintainers = with pkgs.stdenv.lib.maintainers; [ knedlsepp ];
  };

  nodes = let
    fenicsnode = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        (python3.withPackages (ps: with ps; [fenics]))
        openmpi
        gcc
      ];
      networking.firewall.enable = false;
      virtualisation.memorySize = 512;
      services.openssh.enable = true;
      users.users.root.openssh.authorizedKeys.keys = [
        snakeOilPublicKey
      ];
    };
  in
    {
      node1 = fenicsnode;
      node2 = fenicsnode;
    };

  testScript =
    { nodes, ... }:
    ''
      start_all()
      for node in [node1, node2]:
          node.succeed("mkdir -p ~/.ssh")
          node.succeed(
              "cp ${snakeOilPrivateKey} ~/.ssh/id_rsa"
          )
          node.succeed(
              "echo '${snakeOilPublicKey}' > ~/.ssh/id_rsa.pub"
          )
          node.succeed("chmod 600 ~/.ssh/id_rsa")
          node.succeed(
              "cp ${ssh-config} ~/.ssh/config"
          )
          node.wait_for_unit("network-online.target")
          node.wait_for_unit("sshd")
          node.succeed("ls ~/.ssh")
          node.succeed("cat ~/.ssh/config")
          node.succeed("cat ~/.ssh/id_rsa")
          node.succeed("cat ~/.ssh/id_rsa.pub")


      with subtest("Can run on a single node without MPI"):
          node1.succeed("${fenicsScript}")


      with subtest("Can run on a single node using MPI"):
          node1.succeed(
              "mpirun --allow-run-as-root -H node1 \
            ${fenicsScript}"
          )


      ## FIXME: Distributed builds don't work yet (missing backends?)
      # with subtest("Can run on multiple nodes using MPI"):
      #     node1.succeed(
      #         "mpirun --allow-run-as-root -H node1 -H node2 \
      #       ${fenicsScript}"
      #     )
    '';

})
