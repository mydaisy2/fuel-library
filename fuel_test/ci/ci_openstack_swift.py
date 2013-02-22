from devops.model import Environment, Network
import os
from fuel_test.ci.ci_base import CiBase
from fuel_test.node_roles import NodeRoles


class CiOpenStackSwift(CiBase):
    def node_roles(self):
        return NodeRoles(
            controller_names=['fuel-controller-01', 'fuel-controller-02'],
            compute_names=['fuel-compute-01', 'fuel-compute-02'],
            storage_names=['fuel-swift-05', 'fuel-swift-06', 'fuel-swift-07'],
            proxy_names=['fuel-swiftproxy-08', 'fuel-swiftproxy-09'],
            quantum_names=['fuel-quantum'],
        )


    def env_name(self):
        return os.environ.get('ENV_NAME', 'recipes-swift')

    def quantum_nodes(self):
        return self.nodes().quantums

    def describe_environment(self):
        environment = Environment(self.environment_name)
        public = Network(name='public', dhcp_server=True)
        environment.networks.append(public)
        internal = Network(name='internal', dhcp_server=True)
        environment.networks.append(internal)
        private = Network(name='private', dhcp_server=False)
        environment.networks.append(private)
        master = self.describe_node('master', [public, internal, private])
        environment.nodes.append(master)
        for node_name in self.node_roles().controller_names:
            client = self.describe_node(node_name, [public, internal, private])
            environment.nodes.append(client)
        for node_name in self.node_roles().quantum_names:
            client = self.describe_node(node_name, [public, internal, private])
            environment.nodes.append(client)
        for node_name in self.node_roles().compute_names:
            client = self.describe_node(
                node_name, [public, internal, private], memory=4096)
            environment.nodes.append(client)
        for node_name in self.node_roles().storage_names:
            client = self.describe_node(node_name, [public, internal, private])
            environment.nodes.append(client)
        for node_name in self.node_roles().proxy_names:
            client = self.describe_node(node_name, [public, internal, private])
            environment.nodes.append(client)
        return environment
