import random

def generate_input_file(filename, num_values):
    input_data = []
    with open(filename, 'w') as f:
        for i in range(num_values):
            value = random.randint(-10, 100)
            f.write(str(value) + '\n')
            input_data.append(value)
    return input_data

def save_file(filename, values):
    with open(filename, "w") as f:
        for v in values:
            f.write(str(v) + "\n")
    return
    

if __name__ == "__main__":
    # generate the input and output data for basic tests.
    random.seed(16)
    size = 5
    input_file1 = "./input/input1.txt"
    input_file2 = "./input/input2.txt"
    
    input1 = generate_input_file(input_file1, size)
    input2 = generate_input_file(input_file2, size)
    
    add = [input1[i] + input2[i] for i in range(size)]
    sub = [input1[i] - input2[i] for i in range(size)]
    mul = [input1[i] * input2[i] for i in range(size)]
    comp = [input1[i] > input2[i] for i in range(size)]
    eq = [input1[i] == input2[i] for i in range(size)]
    zgt = [1 if sub[i] > 0 else 0 for i in range(size)]
    
    add_file = "./data/add.txt"
    sub_file = "./data/sub.txt"
    mul_file = "./data/mul.txt"
    comp_file = "./data/comp.txt"
    eq_file = "./data/eq.txt"
    zgt_file = "./data/zgt.txt"
    
    save_file(add_file, add)
    save_file(sub_file, sub)
    save_file(mul_file, mul)
    save_file(comp_file, comp)
    save_file(eq_file, eq)
    save_file(zgt_file, zgt)
    
    
    
    
    
    