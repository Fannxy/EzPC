import os
import argparse
import random
import multiprocessing


def generate_input_file(filename, num_values):
    input_data = random.choices(range(-10, 101), k=num_values)
    with open(filename, 'w') as f:
        values = random.choices(range(-10, 101), k=num_values)
        for i in range(num_values):
            # value = random.randint(-10, 100)
            f.write(str(values[i]) + '\n')
            # input_data.append(value)
    return input_data


def save_file(filename, values):
    with open(filename, "w") as f:
        for v in values:
            f.write(str(v) + "\n")
    return


def get_result(func, input1, input2):
    size = len(input1)
 
    if func == 'add':  
        result = [input1[i] + input2[i] for i in range(size)]  
    elif func == 'sub':  
        result = [input1[i] - input2[i] for i in range(size)]  
    elif func == 'mul':  
        result = [input1[i] * input2[i] for i in range(size)]  
    elif func == 'gt':  
        result = [int(input1[i] > input2[i]) for i in range(size)]  
    elif func == 'ge':  
        result = [int(input1[i] >= input2[i]) for i in range(size)]  
    elif func == 'eq':  
        result = [int(input1[i] == input2[i]) for i in range(size)]
    elif func == 'zgt':  
        sub = [input1[i] - input2[i] for i in range(size)]  
        result = [1 if sub[i] > 0 else 0 for i in range(size)]  
    else:  
        raise ValueError('NOT SUPPORTED FUNC ' + func)
      
    return result


beginning_string = """
(*
Name:        Basic Building Blocks Test.
Author:      Fanxy
Description: Test the basic functions, this file is generated automatically by test_basic.py
*)\n\n
"""

extern_string = """
extern void initialize();
extern void finalize();
extern void EndComputation();\n\n
"""

extern_func = ""
target_func = ""
input_string = """
    int32_pl size = INT_SIZE;
    input(SERVER, A, int64_al[size]);
    input(CLIENT, B, int64_al[size]);
    initialize();
    int64_al[size] res;
"""
output_string = """
    EndComputation();
"""

main_begin_string = """
def void main(){\n
"""

main_end_string = """
}
"""

if __name__ == "__main__":
    input_folder = "./input/"
    res_folder = "./data/"
    log_folder = "./log/"
    target_ezpc = "./main.ezpc"
    
    parser = argparse.ArgumentParser(description='这是一个参数解析程序')  
  
    # 添加参数  
    parser.add_argument('--func', type=str, help='test funcs')  
    parser.add_argument('--bitlen', type=int, help='bit length')  
    parser.add_argument('--num_threads', type=int, help='num of threads')  
    parser.add_argument('--size', type=int, help='input size')
    parser.add_argument("--output", type=bool, help='output result or not')
    parser.add_argument("--data_generation", type=bool, help="generate the data or not")
  
    # 解析命令行参数  
    args = parser.parse_args()  
  
    # 输出参数值  
    print('函数名:', args.func)  
    print('比特长度:', args.bitlen)
    print('input size:', args.size)
    
    # generate the programs.
    input_string = input_string.replace("INT_SIZE", str(args.size))
    if(args.output): 
        output_string = output_string + "    output(CLIENT, res);\n"
    
    if(args.func == "add"):
        extern_func = "extern void ElemWiseSecretSharedAdd(int32_pl s1, int64_al[s1] arr1, int64_al[s1] arr2, int64_al[s1] outArr);\n"
        target_func = "    ElemWiseSecretSharedAdd(size, A, B, res);\n"
    elif(args.func == "sub"):
        extern_func = "extern void ElemWiseSecretSharedSub(int32_pl s1, int64_al[s1] arr1, int64_al[s1] arr2, int64_al[s1] outArr);\n"
        target_func = "    ElemWiseSecretSharedSub(size, A, B, res);\n"
    elif(args.func == "mul"):
        extern_func = "extern void ElemWiseSecretSharedVectorMult(int32_pl s1, int64_al[s1] arr1, int64_al[s1] arr2, int64_al[s1] outArr);\n"
        target_func = "    ElemWiseSecretSharedVectorMult(size, A, B, res);\n"
    elif(args.func == "gt"):
        extern_func = "extern void ElemWiseGT(int32_pl s1, int64_al[s1] arr1, int64_al[s1] arr2, int64_al[s1] outArr);"
        target_func = "    ElemWiseGT(size, A, B, res);\n"
    elif(args.func == "ge"):
        extern_func = "extern void ElemWiseGE(int32_pl s1, int64_al[s1] arr1, int64_al[s1] arr2, int64_al[s1] outArr);"
        target_func = "    ElemWiseGE(size, A, B, res);\n"
    elif(args.func == "eq"):
        extern_func = "extern void ElemWiseEQ(int32_pl s1, int64_al[s1] arr1, int64_al[s1] arr2, int64_al[s1] outArr);"
        target_func = "    ElemWiseEQ(size, A, B, res);\n"
    
    program = beginning_string + extern_string + extern_func + main_begin_string + input_string + target_func + output_string + main_end_string
    
    with open(target_ezpc, "w") as f:
        f.write(program)
    
    # generate the inputs.
    if(args.data_generation):
        input_file1 = input_folder + "input1.txt"
        input_file2 = input_folder + "input2.txt"
        res_file = res_folder + "res.txt"
        
        input1 = generate_input_file(input_file1, args.size)
        input2 = generate_input_file(input_file2, args.size)
        result = get_result(args.func, input1, input2)
        save_file(res_file, result)
    
    # generate the execution file and data.
    # os.popen("./run.sh 1 1")